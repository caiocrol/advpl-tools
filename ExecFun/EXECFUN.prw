#Include 'Protheus.ch'

/*/
@author: caio.lima
@data: 29/09/2016
@descricao: Funcao que executa a funcao digitada
//*/

User Function EXECFUN()

	Local cDigit := MemoRead("\system\"+procname()+".txt")
	Local cSelec := ""

	While sAviso("Digite a função a executar", @cDigit, {"Executar", "Cancelar"}, .T., @cSelec) == 1
		If Empty(cSelec)
			MsgAlert("Favor selecionar qual parte do texto deseja macro executar.")
		Else
			macroExec(cSelec, cDigit)
			cvar := xxvar
		EndIf
	End

	MemoWrite("\system\"+procname()+".txt" , cDigit)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} macroExec
@author Caio Lima
@since 11/04/2022
//-----------------------------------------------------------------*/
Static Function macroExec(cSelec, cDigit)
	Local oError
	// Define um code block de tratamento de erro e guarda o code block atual
	Local bError := Errorblock({|e| oError := e, Break(e) })
	Local _cError := ""
	
	If ValType(oError) = "O"
		oError:FreeChildren()
		FreeObj(oError)
	EndIf

	Begin Sequence
		MemoWrite("\system\"+procname()+".txt" , cDigit)
		//Eval({|| &(cSelec) })
		&(cSelec)
	Recover
		_cError := oError:Description + CRLF + CRLF
		_cError += oError:ErrorStack
		//cSelect1 := VarInfo("Prop" , oError)
		Aviso( "Erro", _cError ,{"OK"},4,,,, .T.)
	End Sequence

	// Restaura o code block de tratamento de erro original
	ErrorBlock( bError )
Return

/*/{Protheus.doc} CFG019MNU
PE para adicionar rotina no menu
@author Caio.Lima
@since 06/08/2020
/*/
User Function CFG019MNU()
	aAdd(aRotina,{"Executa funcao","U_EXECFUN()" ,0,3,0, NIL} )
	//aAdd(aRotina,{"Macro executa xbigfor","U_FXBIGFOR()" ,0,4,0, NIL} )
	//aAdd(aRotina,{"Executa Formula","U_FEXECFOR()" ,0,4,0, NIL} )
Return

/*/{Protheus.doc} FXBIGFOR
altera para macro executar o campo de formula grande
@author Caio.Lima
@since 28/10/2020
/*/
User Function FXBIGFOR()
	//Local _cXBigFor := '&(StrTran(StrTran(SM4->M4_XBIGFOR,CHR(13),""),CHR(10),""))'
	Local _cXBigFor := '&(SM4->M4_XBIGFOR)'

	If Upper(AllTrim(SM4->M4_FORMULA)) <> _cXBigFor
		If MsgYesNo("Confirma a alterção dessa formula para macro executar?")
			RecLock("SM4" ,  .F. )
			SM4->M4_XBIGFOR := AllTrim(SM4->M4_FORMULA)
			SM4->M4_FORMULA := _cXBigFor
			SM4->(MsUnlock())

			MsgInfo("Formula alterada")
		EndIf
	Else
		If MsgYesNo("Essa formula já é macro executada, deseja alterar para a formula normal?")
			If Len(AllTrim(SM4->M4_XBIGFOR)) > TamSX3("M4_FORMULA")[1]
				MsgAlert("O conteudo do campo formula grande não cabe no campo M4_FORMULA, alteração não pode ser efetuada.")
			Else
				RecLock("SM4" ,  .F. )
				SM4->M4_FORMULA := AllTrim(SM4->M4_XBIGFOR)
				SM4->M4_XBIGFOR := ""
				SM4->(MsUnlock())

				MsgInfo("Formula alterada")
			EndIf
		EndIf
	EndIf
Return

/*/{Protheus.doc} FEXECFOR
	executa a formula
@author Caio.Lima
@since 28/10/2020
/*/
User Function FEXECFOR()
	If MsgYesNo("Confirma a execução?")
		&(SM4->M4_FORMULA)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getStackTrace
	Retorna o strack trace do ponto em que foi executada
@author Caio Lima
@since 20/04/2022
//-----------------------------------------------------------------*/
User function getStackTrace(lConOut)
	Local _nProc := 0
	Local _cStack := ""
	Local _cRet := ""

	Default lConOut := .F.

	While !Empty(_cStack := ProcName(_nProc))
		_cRet += Padl(_cStack, 40) + " | (Linha: " + PadR(cValToChar(ProcLine(_nProc)), 7)+")" + " | "  + ProcSource(_nProc) + CRLF
		_nProc++
	EndDo
	If lConOut
		ConOut(_cRet)
	EndIF
Return(_cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} sAviso
	Função aviso customizada
@author Caio Lima
@since 02/12/2021
//-----------------------------------------------------------------*/
Static FUNCTION sAviso(cCaption,cMensagem,aBotoes,_lHabDigt, cSelec)

	Local ny        := 0
	Local nx        := 0
	Local nLinha    := 0
	Local cMsgButton:= ""
	Local oGet
	Local oTimer
	Local _nSize := 0
	Local _nLin := Len(StrTokArr(cMensagem, CRLF))
	Local _nLinSize := 12
	Local _aCoor := MsAdvSize(.F.)
	Local _a1
	Local _a4
	Local _aObjV
	Local _oFCons16 := TFont():New("Consolas",,18,,.T.,,,,,.F.,.F.)
	Local _aBtn := {}

	Default _lHabDigt := .F.

	Private oDlgAviso
	Private nOpcAviso := 0

	// para fixar um tamanho de tela
	_aCoor[5] := 600 // largura da janela
	_nSize := ((_nLin * _nLinSize) + 15) * 2
	If _nSize > 800
		_nSize := 800
	ElseIf _nSize < 300
		_nSize := 250
	EndIf
	_aCoor[6] := _nSize // altura da janela
	_aCoor[3] := _aCoor[5] / 2
	_aCoor[4] := _aCoor[6] / 2

	_a1 := {_aCoor[1],_aCoor[2],_aCoor[3],_aCoor[4],3,3}
	_a2 := {{200,200,.T.,.T.,.T.}, {37,18,.F.,.F.,.T.}}
	_aObj := MsObjSize(_a1 , _a2 , .T. , .F. ) // ultimo par: .T. -> Horizontal, .F.-> vertical

	DEFINE MSDIALOG oDlgAviso FROM 0,0 TO _aCoor[6],_aCoor[5] TITLE cCaption Of oMainWnd PIXEL

	oGet := TSimpleEditor():New( _aObj[1,1],_aObj[1,2], oDlgAviso, _aObj[1,3],_aObj[1,4], , !_lHabDigt, , , .T. )
	oGet:Load(cMensagem)

	If Len(aBotoes) > 1
		TButton():New(1000,1000," ",oDlgAviso,{||Nil},32,10,,_oFCons16,.F.,.T.,.F.,,.F.,,,.F.)
	EndIf
	ny := 05
	For nx:=1 to Len(aBotoes)
		_nLarg := Len(aBotoes[nx]) * 4 + 10
		If _nLarg < 25
			_nLarg := 25
		EndIf

		cAction:="{||nOpcAviso:="+Str(nx)+", cMensagem := oGet:RetText(), cSelec := oGet:RetTextSel(),oDlgAviso:End()}"
		bAction:=&(cAction)
		cMsgButton:= OemToAnsi(AllTrim(aBotoes[nx]))
		cMsgButton:= IF( ( "&" $ SubStr( cMsgButton , 1 , 1 ) ) , cMsgButton , ( "&"+cMsgButton ) )
		Aadd(_aBtn, TButton():New(_aObj[2,1], ny ,cMsgButton, oDlgAviso,bAction,_nLarg,15,,_oFCons16,.F.,.T.,.F.,,.F.,,,.F.) )
		If nx == 1
			_aBtn[nx]:SetFocus()
		EndIf
		ny += _nLarg + 3
	Next nx

	ACTIVATE MSDIALOG oDlgAviso CENTERED

	//cMensagem := oGet:RetText()
	//cSelec := oGet:RetTextSel()

Return (nOpcAviso)

/*/{Protheus.doc} ZSIGAESP
    Chama a função diretamente sem passar pelo menu
    passando pela autenticação e abertura da empresa
@author Caio.Lima
@since 05/04/2022
/*/
User Function XSIGAESP()
    Local cModulo 	:= 'SIGAESP' //Nome do Módulo que irá fazer a abertura do Smartclient

    MsApp():New(cModulo) //Instancia a aplicação no módulo
    oApp:cInternet := NIL     
    oApp:CreateEnv() //Cria o ambiente que será usando
    PtSetTheme("OCEAN") //Define o nome do tema, se não inserir, será considerado o tema padrão
    oApp:cStartProg    	:= 'U_EXECFUN' //Instancia a função que será executada após a abertura do programa
    oApp:lMessageBar	:= .T. 
    oApp:cModDesc		:= cModulo
    __lInternet 		:= .T.
    lMsFinalAuto 		:= .F.
    oApp:lMessageBar	:= .T. 
    oApp:Activate() //Executa
Return
