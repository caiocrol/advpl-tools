#INCLUDE "PROTHEUS.CH"
#INCLUDE "RwMake.CH"

/*/{Protheus.doc} ZSIGAESP
    Chama a função diretamente sem passar pelo menu
    passando pela autenticação e abertura da empresa
@author Caio.Lima
@since 05/04/2022
/*/
User Function ZSIGAESP()
    Local cModulo 	:= 'SIGAESP' //Nome do Módulo que irá fazer a abertura do Smartclient

    MsApp():New(cModulo) //Instancia a aplicação no módulo
    oApp:cInternet := NIL     
    oApp:CreateEnv() //Cria o ambiente que será usando
    PtSetTheme("OCEAN") //Define o nome do tema, se não inserir, será considerado o tema padrão
    oApp:cStartProg    	:= 'U_ZZSIGAESP' //Instancia a função que será executada após a abertura do programa
    oApp:lMessageBar	:= .T. 
    oApp:cModDesc		:= cModulo
    __lInternet 		:= .T.
    lMsFinalAuto 		:= .F.
    oApp:lMessageBar	:= .T. 
    oApp:Activate() //Executa
Return

User Function ZZSIGAESP()
    Alert("Olá mundo!")
Return
