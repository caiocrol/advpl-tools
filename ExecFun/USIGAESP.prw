#INCLUDE "PROTHEUS.CH"
#INCLUDE "RwMake.CH"

/*/{Protheus.doc} ZSIGAESP
    Chama a fun��o diretamente sem passar pelo menu
    passando pela autentica��o e abertura da empresa
@author Caio.Lima
@since 05/04/2022
/*/
User Function ZSIGAESP()
    Local cModulo 	:= 'SIGAESP' //Nome do M�dulo que ir� fazer a abertura do Smartclient

    MsApp():New(cModulo) //Instancia a aplica��o no m�dulo
    oApp:cInternet := NIL     
    oApp:CreateEnv() //Cria o ambiente que ser� usando
    PtSetTheme("OCEAN") //Define o nome do tema, se n�o inserir, ser� considerado o tema padr�o
    oApp:cStartProg    	:= 'U_ZZSIGAESP' //Instancia a fun��o que ser� executada ap�s a abertura do programa
    oApp:lMessageBar	:= .T. 
    oApp:cModDesc		:= cModulo
    __lInternet 		:= .T.
    lMsFinalAuto 		:= .F.
    oApp:lMessageBar	:= .T. 
    oApp:Activate() //Executa
Return

User Function ZZSIGAESP()
    Alert("Ol� mundo!")
Return
