/* ======================================
	ZC_Interaction
   ======================================
	Mostly copied from Unofficial Mod.
   ====================================== */

class ZC_Interaction extends Interaction
	abstract;

var KFPlayerController OwningKFPC;
var Console GameConsole;

function ConsoleMsg(string Message)
{
	if (GameConsole == None)
		GameConsole = class'Engine.Engine'.static.GetEngine().GameViewport.ViewportConsole;
		
	if (GameConsole != None)
		GameConsole.OutputTextLine(Message);
}

function bool CheckPlayerAdmin()
{
	local bool bAdmin;

	bAdmin = (OwningKFPC.WorldInfo.NetMode == NM_Standalone || OwningKFPC.PlayerReplicationInfo.bAdmin);
	
	if (!bAdmin)
		ConsoleMsg("This function is only available to solo players and server admins!");
		
	return bAdmin;
}

exec function HatsIgnoreStalkers(bool bIgnore)
{
	if(CheckPlayerAdmin())
		OwningKFPC.ConsoleCommand("Mutate HatsIgnoreStalkers" @ bIgnore, false);
}

exec function SetHatType(string HatStr)
{
	if(CheckPlayerAdmin())
		OwningKFPC.ConsoleCommand("Mutate SetHatType" @ HatStr, false);
}