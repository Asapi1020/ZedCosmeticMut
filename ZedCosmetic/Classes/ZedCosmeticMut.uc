// ====================================================================
//	ZedCosmeticMut by Asapi1020
// ====================================================================
//	This mutator force zeds wear a hat.
//	Inspired by a Weekly Outbreak "WildWestLondon".
//	You can read an official code in "KFGame.KFCharacterInfo_Monster".
// 	It may help you to understand what is written here.
//	I tried making console commands to change config values in game
//	but I haven't completed yet.
// ====================================================================

class ZedCosmeticMut extends KFMutator
	config(ZedCosmetic);

var array<string> MeshPathes;
var transient LinearColor ZC_MonoChromeValue;
var transient LinearColor ZC_ColorValue;

var config int Version;
var config bool IgnoreStalkers;
var config string HatType;

event PostBeginPlay()
{
	super.PostBeginPlay();

	SetupInteraction();
	SetupConfig();

	SaveConfig();
}

function SetupInteraction()
{
	local KFPlayerController KFPC;
	local ZC_Interaction ZCI;

	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		ZCI = new (KFPC) class'ZC_Interaction';
		ZCI.OwningKFPC = KFPC;
		KFPC.Interactions.AddItem(ZCI);
	}
}

function SetupConfig()
{
	if(Version < 1)
	{
		IgnoreStalkers = true;
		HatType = "random";
		Version = 1;
	}
}

//	Not functional now (I guess I should learn more)
function Mutate(string MutateString, PlayerController Sender)
{
	local array<string> StringParts;

	if (WorldInfo.NetMode == NM_Standalone || Sender.PlayerReplicationInfo.bAdmin)
	{
		StringParts = SplitString(MutateString, " ", true);

		if(StringParts[0] ~= "HatsIgnoreStalkers")
			IgnoreStalkers = bool(StringParts[1]);

		else if (StringParts[0] ~= "SetHatType")
			HatType = StringParts[1];
	}
}

//	main function

function ModifyAI( Pawn AIPawn )
{
	local KFPawn KFP;
	local int i;
	local StaticAttachments NewAttachment;
	local StaticMeshComponent StaticAttachment;
	local MaterialInstanceConstant NewMIC;

	super.ModifyAI(AIPawn);

	KFP = KFPawn(AIPawn);

	if( KFP != none && KFPawn_Monster(KFP) != none &&
		!(KFGameReplicationInfo(KFP.WorldInfo.GRI).bIsWeeklyMode && (class'KFGameEngine'.static.GetWeeklyEventIndexMod() == 12)) &&
		!(IgnoreStalkers && KFPawn_ZedStalker(KFP) != none))
	{
		if(HatType ~= "cowboy")
			i = 0;
		else if(HatType ~= "xmas")
			i = 1 + Rand(8);
		else if(HatType ~= "halloween")
			i = 9 + Rand(9);
		else
			i = Rand(MeshPathes.length);

		NewAttachment.StaticAttachment = StaticMesh(DynamicLoadObject(MeshPathes[i], class'StaticMesh'));
		NewAttachment.AttachSocketName = KFPawn_Monster(KFP).ZEDCowboyHatAttachName;

		StaticAttachment = new (KFP) class'StaticMeshComponent';
		if (StaticAttachment != none)
		{
			KFPawn_Monster(KFP).StaticAttachList.AddItem(StaticAttachment);
			StaticAttachment.SetActorCollision(false, false);
			StaticAttachment.SetStaticMesh(NewAttachment.StaticAttachment);
			StaticAttachment.SetShadowParent(KFP.Mesh);
			StaticAttachment.SetLightingChannels(KFP.PawnLightingChannel);
			NewMIC = StaticAttachment.CreateAndSetMaterialInstanceConstant(0);
			NewMIC.SetVectorParameterValue('color_monochrome', ZC_MonoChromeValue);
			NewMIC.SetVectorParameterValue('Black_White_switcher', ZC_ColorValue);
			KFP.AttachComponent(StaticAttachment);
			KFP.Mesh.AttachComponentToSocket(StaticAttachment, NewAttachment.AttachSocketName);
			KFP.CharacterMICs.AddItem(NewMIC);
		}
	}
}

defaultproperties
{
	MeshPathes.Add("CHR_CosmeticSet01_MESH.cowboyhat.CHR_CowboyHat_Alberts_Cosmetic")// 0
	MeshPathes.Add("CHR_Cosmetic_XMAS_MESH.CHR_PoinsettaHat_Cosmetic") //1
	MeshPathes.Add("CHR_Cosmetic_XMAS_MESH.CHR_Ushanka_Cosmetic")
	MeshPathes.Add("CHR_CosmeticSet_XMAS_02_MESH.CHR_Cosmetic_Halloween_ChimneyHat")
	MeshPathes.Add("CHR_CosmeticSet_XMAS_02_MESH.CHR_Cosmetic_Halloween_Treeyhat")
	MeshPathes.Add("CHR_CosmeticSet_XMAS_02_MESH.CHR_Cosmetic_Halloween_Penguinhat")
	MeshPathes.Add("CHR_CosmeticSet_XMAS_03_MESH.snowmancap.CHR_Cosmetic_XMas19_SnowmanCap_LOD1")
	MeshPathes.Add("CHR_CosmeticSet_XMAS_03_MESH.TopHat.CHR_Cosmetic_XMas19_TopHat_LOD0")
	MeshPathes.Add("CHR_CosmeticSet_XMAS_03_MESH.clotthat.CHR_Cosmetic_XMas19_ClotHat_LOD0")
	MeshPathes.Add("CHR_CosmeticSet_Halloween_01_MESH.CHR_Cosmetic_Halloween_Axed") // 9
	MeshPathes.Add("CHR_CosmeticSet_Halloween_02_MESH.CHR_Cosmetic_Halloween_PirateHat")
	MeshPathes.Add("CHR_CosmeticSet_Halloween_02_MESH.CHR_Cosmetic_Halloween_WitchHat")
	MeshPathes.Add("CHR_CosmeticSet_Halloween_03_MESH.batcathat.CHR_Cosmetic_Halloween19_BatCatHat")
	MeshPathes.Add("CHR_CosmeticSet_Halloween_03_MESH.biohazardhat.CHR_Cosmetic_Halloween19_BiohazardHat")
	MeshPathes.Add("CHR_CosmeticSet_Halloween_03_MESH.monsterwitchhat.CHR_Cosmetic_Halloween19_MonsterWitchHat")
	MeshPathes.Add("CHR_CosmeticSet_Halloween_03_MESH.pumpkinhat.CHR_Cosmetic_Halloween19_PumpkinHat")
//	MeshPathes.Add("CHR_CosmeticSet_Halloween_04_MESH.CHR_HalloweenFingerTophat_Cosmetic") // This item doesn't work properly
	MeshPathes.Add("CHR_CosmeticSet_Halloween_04_MESH.CHR_HalloweenSorceressHat_Cosmetic")
	MeshPathes.Add("CHR_CosmeticSet_Halloween_05_MESH.muertos_tophat.CHR_MuertosTopHat_Cosmetic")
	MeshPathes.Add("CHR_CosmeticSet_Spring_01_MESH.cyborg_brainhelmet.CHR_CyborgBrainHelmet_Cosmetic")	// 19 // 18
	MeshPathes.Add("CHR_CosmeticSet_SS_01_MESH.CHR_Clown_Hat")
	MeshPathes.Add("CHR_CosmeticSet_SS_01_MESH.CHR_Tiny_Hat_Alberts")
	MeshPathes.Add("CHR_CosmeticSet_SS_01_MESH.CHR_Witchdoctor_Hat")
	MeshPathes.Add("CHR_CosmeticSet_Steampunk01_MESH.flatcap.SP_FlatCap_Mesh")
	MeshPathes.Add("CHR_CosmeticSet_Steampunk01_MESH.TopHat.SP_TopHat_Mesh")
	MeshPathes.Add("CHR_CosmeticSet01_MESH.chefhat.CHR_ChefHat_Alberts_Cosmetic_LOD0_LOD0")

	ZC_MonoChromeValue = (R=1.0f,G=0.0f,B=0.0f)
	ZC_ColorValue = (R=1.0f,G=0.0f,B=0.0f)
}