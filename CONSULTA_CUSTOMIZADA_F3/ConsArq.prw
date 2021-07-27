#include "Rwmake.ch"
#include "Protheus.ch"

Static _cRetConp

#DEFINE GETF_ONLYSERVER                   0
#DEFINE GETF_OVERWRITEPROMPT              1
#DEFINE GETF_MULTISELECT                  2
#DEFINE GETF_NOCHANGEDIR                  4
#DEFINE GETF_LOCALFLOPPY                  8
#DEFINE GETF_LOCALHARD                   16
#DEFINE GETF_NETWORKDRIVE                32
#DEFINE GETF_SHAREAWARE                  64
#DEFINE GETF_RETDIRECTORY               128

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  |ConsArq   บAutor  ณCaio Renan          บ Data ณ30/04/2013              บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                       บฑฑ
ฑฑบ          ณ                                                                       บฑฑ
ฑฑบ          ณ                                                                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function ConsArq(_nOpc, _cTipo)
Local _cVar := &(ReadVar())
//Local _cTipo := "Arquivos de texto (*.txt) |*.txt|Arquivos xml(*.xml) |*.xml|Todos (*.*)|*.*"
Local _nTipo := 2
Local _lSalvar := .F.
Default _nOpc := 1
Default _cTipo := "Arquivos de texto (*.txt) |*.txt|Arquivos xml(*.xml) |*.xml|Todos (*.*)|*.*"

If _nOpc == 1
	_lSalvar := .F.
	_nRetDirectory := GETF_LOCALHARD
Else
	_lSalvar := .T.
	_cTipo := ""
	_nRetDirectory := GETF_RETDIRECTORY + GETF_LOCALHARD
EndIf

_cRetConp := cGetFile(_cTipo,"Selecione o arquivo",_nTipo,_cVar,_lSalvar,_nRetDirectory)

/*
_cRetConp := cGetFile("Arquivos xml(*.xml) |*.xml|Todos (*.*)|*.*","Selecione o arquivo",2,_cVar,.F.,GETF_RETDIRECTORY + GETF_LOCALHARD)
*/

Return !(empty(_cRetConp))

User Function RetArq()
Return(_cRetConp)
