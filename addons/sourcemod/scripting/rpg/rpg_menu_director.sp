/* put the line below after all of the includes!
#pragma newdecls required
*/

stock void BuildDirectorPriorityMenu(int client) {

	Handle menu						=	CreateMenu(BuildDirectorPriorityMenuHandle);

	int size							=	GetArraySize(a_DirectorActions);
	char Name[64];
	char Name_t[64];

	char key[64];
	char value[64];

	int Priority						=	0;

	for (int i = 0; i < size; i++) {

		MenuKeys[client]							=	GetArrayCell(a_DirectorActions, i, 0);
		MenuValues[client]							=	GetArrayCell(a_DirectorActions, i, 1);
		MenuSection[client]							=	GetArrayCell(a_DirectorActions, i, 2);

		GetArrayString(MenuSection[client], 0, Name, sizeof(Name));
		Format(Name_t, sizeof(Name_t), "%T", Name, client);

		int size2						=	GetArraySize(MenuKeys[client]);
		for (int ii = 0; ii < size2; ii++) {

			GetArrayString(MenuKeys[client], ii, key, sizeof(key));
			GetArrayString(MenuValues[client], ii, value, sizeof(value));

			if (StrEqual(key, "priority?")) Priority		=	StringToInt(value);
		}
		Format(Name_t, sizeof(Name_t), "%s (%d / %d)", Name_t, Priority, GetConfigValueInt("director priority maximum?"));
		AddMenuItem(menu, Name_t, Name_t);
	}
	SetMenuExitBackButton(menu, false);
	DisplayMenu(menu, client, 0);
}

public BuildDirectorPriorityMenuHandle(Handle menu, MenuAction action, int client, int slot) {

	if (action == MenuAction_Select) {

		char key[64];
		char value[64];

		char Priority[64];
		Format(Priority, sizeof(Priority), "0");
		int PriorityMaximum				=	GetConfigValueInt("director priority maximum?");

		MenuKeys[client]							=	GetArrayCell(a_DirectorActions, slot, 0);
		MenuValues[client]							=	GetArrayCell(a_DirectorActions, slot, 1);

		int size						=	GetArraySize(MenuKeys[client]);

		for (int i = 0; i < size; i++) {

			GetArrayString(MenuKeys[client], i, key, sizeof(key));
			GetArrayString(MenuValues[client], i, value, sizeof(value));

			if (StrEqual(key, "priority?")) {

				Format(Priority, sizeof(Priority), "%s", value);

				if (StringToInt(Priority) < PriorityMaximum) Format(Priority, sizeof(Priority), "%d", StringToInt(Priority) + 1);
				else Format(Priority, sizeof(Priority), "1");

				SetArrayString(MenuValues[client], i, Priority);
				SetArrayCell(a_DirectorActions, slot, MenuValues[client], 1);
				break;
			}
		}
		BuildDirectorPriorityMenu(client);
	}
	else if (action == MenuAction_End) {

		CloseHandle(menu);
	}
}
