#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fileio.ch'

/*/{Protheus.doc} CGENX01
Func�o generica para substituir getsxenum
criada para corrigir o fato de existir codigos que n�o devem ser considerados para pegar o proximo.

-> Essa fun��o sempre executa um select MAX para buscar o proximo registro
evitando a perda de posi��es.
-> Permite passar parametros para desconsiderar ou considerar certos codigos, de formas que os 
codigos cadastrados errados n�o interferem para trazer o proximo registro
-> Caso 2 ou mais usuarios busquem o proximo numero a rotina consegue trazer de forma 
correta pois nesse caso ser� utilizado um arquivo criado dinamicamente para buscar 
o proximo numero

Exemplo:
Colocar a fun��o abaixo no inicializador do campo de codigo a ser utilizado
U_CGENX01("SA1","A1_COD","A",,.T.)

@author Caio.Lima
@since 07/04/2020
@param _cTab           , Caractere, Tabela
@param _cCampo         , Caractere, Campo
@param _cInc           , Caractere, Paramentro de inclus�o, caso informado ir� considerar apenas os iniciados com esse caracteres
		baseado no campo passado no segundo parametro, pode ter mais de uma caractere
@param _cExc           , Caractere, Parametro de exclus�o, caso informado N�O ir� considerar os codigos iniciados com os caracteres passados
		baseado no campo passado no segundo parametro, pode ter mais de uma caractere
@param _lCompartilhado , L�gico, Caso true for�a a busca do codigo de forma compartilhado, mesmo para tabelas exclusivas.
@return return, return_description
/*/
User Function CGENX01(_cTab, _cCampo, _cInc, _cExc, _lCompartilhado)
	Local _cReturn := ""
	Local _cDir    := "\" + ProcName()
	Local _cFile   := ""
	Local _lNew := .F.
	Local _nHdl := 0
	
	Default _cInc := ""
	Default _cExc := ""
	Default _lCompartilhado := .F.
	
	If Type("HndCGENX01") <> "N"
		// Variavel publica, dessa forma caso apenas um usuario esteja acessando o arquivo vai poder ser deletado e com isso a numera��o fica correta
		// se mais de um usuario acessar ai n�o ser� possivel deletar o arquivo e com isso o proximo vir� do arquivo n�o do select max
		Public HndCGENX01 := 0
	EndIf
	
	_cFile += "\" + _cTab + _cCampo + _cInc
	If !_lCompartilhado
		_cFile += xFilial(_cTab)
	EndIf
	_cFile := AllTrim(_cFile) + ".txt"
	
	If !ExistDir(_cDir)
		MakeDir(_cDir)
		_lNew := .T.
	Else
		If File(_cDir + _cFile)
			If HndCGENX01 > 0
				FClose(HndCGENX01)
			EndIf
			
			If fErase(_cDir + _cFile) < 0
				ConOut(ProcName() + " - " + _cDir + _cFile + " Arquivo aberto por outra instancia, n�o ser� deletado dessa vez")
			Else
				ConOut(ProcName() + " - " + _cDir + _cFile + " Arquivo excluido com sucesso")
			EndIf
		EndIf
	EndIf
	
	If !File(_cDir + _cFile)
		_nHdl := FCreate(_cDir + _cFile)
		If _nHdl > 0
			FClose(_nHdl)
		EndIf
		
		_lNew := .T.
	EndIf
	
	If _lNew
		_cReturn := fGetNext(_cTab, _cCampo, _cInc, _cExc, _lCompartilhado)
	Else
		_cReturn := MemoRead(_cDir + _cFile)
		_cReturn := Soma1(_cReturn)
	EndIf
	
	// abro em modo leitura e grava��o por�m n�o de forma exclusiva
	HndCGENX01 := FOpen(_cDir + _cFile, FO_READWRITE)
	
	If HndCGENX01 > 0
		FWrite(HndCGENX01, _cReturn)
	EndIf
	
	// n�o fecho o arquivo pois dessa forma garanto que quando tiver mais de uma pessoa utilizando a rotina consegue pegar o proximo correto
	// pois no inicio da rotina tenta excluir o arquivo
	
Return(_cReturn)

/*/{Protheus.doc} fGetNext
pega o proximo numero a partir do select
@author Caio.Lima
@since 07/04/2020
@param _cTab, , descricao
@param _cCampo, , descricao
@param _cInc, , descricao
@param _cExc, , descricao
@param _lCompartilhado, , descricao
@return return, return_description
/*/
Static function fGetNext(_cTab, _cCampo, _cInc, _cExc, _lCompartilhado)
	Local _aArea := GetArea()
	Local _nTamSX3 := TamSX3(_cCampo)[1]
	Local _cRet := Space(_nTamSX3)
	Local _cSql := ""
	Local _nQtdChar := 0
	
	_cALias := GetNextAlias()
	
	_cSql += " SELECT MAX("+_cCampo+") RETORNO FROM " + RetSqlName(_cTab) + " " + CRLF
	_cSql += " WHERE D_E_L_E_T_<>'*' " + CRLF
	
	If !_lCompartilhado
		If !Empty(xFilial(_cTab))
			_cSql += " AND "+Left(_cCampo, At("_",_cCampo) )+"FILIAL = '"+xFilial(_cTab)+"' " 
		EndIf
	EndIf
	
	If !Empty(_cInc)
		_nQtdChar := Len(_cInc)
		_cSql += " AND LEFT(" + _cCampo + ","+cValToChar(_nQtdChar)+") "
		_cSql += " IN ('"+StrTran(_cInc, ",", "','")+"') "
	EndIf

	If !Empty(_cExc)
		_nPV := At(",",_cExc)
		If _nPV > 0
			_nQtdChar := _nPV - 1
		Else
			_nQtdChar := Len(_cExc)
		EndIf
		
		If _nQtdChar == _nTamSX3
			_cSql += " AND " + _cCampo + " "
		Else
			_cSql += " AND LEFT(" + _cCampo + ","+cValToChar(_nQtdChar)+") "
		EndIf
		_cSql += " NOT IN ('"+StrTran(_cExc, ",", "','")+"') "
	EndIf
	
	If Select(_cALias) > 0
		(_cALias)->(dbClosearea())
	Endif
	
	MemoWrite("D:\LOGSQL\"+FunName()+"-"+ProcName()+".txt" , _cSql)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(_cSql)), _cALias, .F., .F.)
	
	If !(_cAlias)->(Eof())
		If !Empty((_cAlias)->RETORNO)
			_cRet := Soma1( (_cAlias)->RETORNO )
		Else
			If !Empty(_cInc)
				_cRet := Soma1(Padr(_cInc, _nTamSX3, "0"))
			Else
				_cRet := Soma1(_cRet)
			EndIf
		EndIf
	Else
		If !Empty(_cInc)
			_cRet := Soma1(Padr(_cInc, _nTamSX3, "0"))
		Else
			_cRet := Soma1(_cRet)
		EndIf
	EndIf
	
	(_cALias)->(dbClosearea())
	
	RestArea(_aArea)
	
Return(_cRet)
