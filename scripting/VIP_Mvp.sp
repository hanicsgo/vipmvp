#pragma tabsize 0

#include <sourcemod>

#include <clientprefs>
#include <sdktools>
#include <sdkhooks>

#include <vip_core>
#include <csgo_colors>

#pragma newdecls required
#pragma semicolon 1

#define VIP_MVP				"MVP"
#define VIP_MVP_MENU		"MVP_Menu"

char g_sChatPrefix[128];

int g_iCount = 0;
int g_sSound;

public Plugin myinfo =
{
	name = "[CS:GO] Custom MVP Anthem to VIPCore by R1kO",
	author = "hani from anhemyenbai",
	version = "1.0",
	description = "Custom MVP Anthem",
	url = ""
};

static const char g_sFeature[] = "MVP";

int g_iEquipt[MAXPLAYERS + 1] = {-1, ...};
Handle g_hCookie;
Menu g_hmenu;

public void OnPluginStart()
{
    VIP_FeatureType("mvp_sound","sound", MVPSounds_OnMapStart, MVPSounds_Reset, MVPSounds_Config, MVPSounds_Equip, MVPSounds_Remove, true);

    HookEvent("round_mvp", Event_RoundMVP);

	LoadTranslations("vip.kento.mvp.phrases");
    LoadTranslations("vip_modules.phrases");
}

public void OnPluginEnd() 
{
	if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_UnregisterFeature") == FeatureStatus_Available)
	{
		VIP_UnregisterFeature(g_sFeature);
	}
}

public int VIP_OnVIPLoaded()
{
	VIP_RegisterFeature("VIP_MVP", BOOL, SELECTABLE);
}

public Action Command_MVP(int client, any args)
{
	if(VIP_IsClientVIP(client) && VIP_IsClientFeatureUse(client, "VIP_MVP"))
	{
		Menu_Chat(client);
	}
	return Plugin_Handled;
}

public void MVPSounds_OnMapStart()
{
	char sBuffer[256];

	for (int i = 0; i < g_iCount; i++)
	{
		PrecacheSound(g_sSound[i], true);
		FormatEx(sBuffer, sizeof(sBuffer), "sound/%s", g_sSound[i]);
		AddFileToDownloadsTable(sBuffer);
	}
}

public void MVPSounds_Reset()
{
	g_iCount = 0;
}

public bool MVPSounds_Config(KeyValues &kv, int itemid)
{
	ItemDisplayCallback(itemid, g_iCount);

	kv.GetString("sound", g_sSound[g_iCount], PLATFORM_MAX_PATH);

	char sBuffer[256];
	FormatEx(sBuffer, sizeof(sBuffer), "sound/%s", g_sSound[g_iCount]);

	g_fVolume[g_iCount] = kv.GetFloat("volume", 0.5);

	if (g_fVolume[g_iCount] > 1.0)
	{
		g_fVolume[g_iCount] = 1.0;
	}

	if (g_fVolume[g_iCount] <= 0.0)
	{
		g_fVolume[g_iCount] = 0.05;
	}

	g_iCount++;

	return true;
}

public int MVPSounds_Equip(int client, int itemid)
{
	g_iEquipt[client]

	return 0;
}

public int MVPSounds_Remove(int client, int itemid)
{
	g_iEquipt[client] = -1;

	return 0;
}

public void OnClientDisconnect(int client)
{
	g_iEquipt[client] = -1;
}


public void Event_RoundMVP(Event event, char[] name, bool dontBroadcast)
{
	if (!gc_bEnable.BoolValue)
		return;

	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!client)
		return;

	if (g_iEquipt[client] == -1)
		return;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i))
			continue;

		//if (g_bHide[client])
		//	continue;

		ClientCommand(i, "playgamesound Music.StopAllMusic");

		EmitSoundToClient(i, g_sSound[g_iEquipt[client]], client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, g_fVolume[g_iEquipt[client]]);
	}

}



