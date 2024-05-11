/*
*	Extra Menu API
*	Copyright (C) 2022 Silvers
*
*	This program is free software: you can redistribute it and/or modify
*	it under the terms of the GNU General Public License as published by
*	the Free Software Foundation, either version 3 of the License, or
*	(at your option) any later version.
*
*	This program is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*	GNU General Public License for more details.
*
*	You should have received a copy of the GNU General Public License
*	along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#if defined _extra_menu_api_included
 #endinput
#endif
#define _extra_menu_api_included



public SharedPlugin __pl_extramenu = 
{
	name = "extra_menu",
	file = "extra_menu.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_extramenu_SetNTVOptional()
{
	MarkNativeAsOptional("ExtraMenu_Create");
	MarkNativeAsOptional("ExtraMenu_Delete");
	MarkNativeAsOptional("ExtraMenu_AddOptions");
	MarkNativeAsOptional("ExtraMenu_AddEntry");
	MarkNativeAsOptional("ExtraMenu_NewPage");
	MarkNativeAsOptional("ExtraMenu_Display");
}
#endif


// Different row types allowed in the menu
enum EXTRA_MENU_TYPE
{
	MENU_ENTRY,				// Simple row of text, not selectable
	MENU_SELECT_ONLY,		// Entry that can be selected
	MENU_SELECT_ONOFF,		// Entry that will turn on/off when selected
	MENU_SELECT_LIST,		// Scroll through a list of entries
	MENU_SELECT_ADD,		// Entry that will increment and decrement a value
}



/**
* @brief Creates a new menu.
*
* @param	back			Gives a "Previous" option to the menu on the 1st page, useful to return to another menu
* @param	translation		Path to a translation file used for "ExtraMenu_AddEntry" entries or "" for no translation
* @param	buttons_nums	Menu movement type. False = W/A/S/D (freezes player). True = 1/2/3/4 (does not freeze player)
*
* @return	menu_id, the handle used to to add entries, display and delete the menu.
*/
native int ExtraMenu_Create(bool back = false, char[] translation = "", bool buttons_nums = false);

/**
* @brief Deletes the specified menu.
*
* @param	menu_id			The menu ID to delete, returned from ExtraMenu_Create()
*
* @return	True on success, false otherwise (possibly if menu is not available).
*/
native bool ExtraMenu_Delete(int menu_id);

/**
* @brief Adds a row entry to the menu, either non-selectable text or an option to select.
*
* @param	menu_id			The menu ID to modify, returned from ExtraMenu_Create()
* @param	entry			The row string (can include "_OPT_" which will be replaced with [ ] and [X] for "MENU_SELECT_ONOFF" or the value for "MENU_SELECT_ADD" or "MENU_SELECT_LIST" types)
* @param	type			Type of entry (see the "MENU_*" variables)
* @param	close			Close the menu after selecting an option.
* @param	default_value	Default value for the "MENU_SELECT_ONOFF" and "MENU_SELECT_ADD" types.
* @param	add_value		Value to increment/decrement by when selecting (for use with "MENU_SELECT_ADD" type) (float values are supported)
* @param	add_min			Minimum value when using increment/decrement (for use with "MENU_SELECT_ADD" type) (float values are supported)
* @param	add_max			Maximum value when using increment/decrement (for use with "MENU_SELECT_ADD" type) (float values are supported)
*
* @return	True on success, false otherwise (possibly if menu is not available).
*/
native bool ExtraMenu_AddEntry(int menu_id, char[] entry, EXTRA_MENU_TYPE type, bool close = false, int default_value = 0, any add_value = 0, any add_min = -999999, any add_max = 999999);

/**
* @brief Adds a set of options to scroll through, for use with the "MENU_SELECT_LIST" type.
*
* @param	menu_id			The menu ID to modify, returned from ExtraMenu_Create()
* @param	entry			The string of options to scroll through, each entry separated by the "|" character
*
* @return	True on success, false otherwise (possibly if menu is not available).
*/
native bool ExtraMenu_AddOptions(int menu_id, char[] entry);

/**
* @brief Adds the next "ExtraMenu_AddEntry" data to a new page and creates the "Next Page" and "Previous Page" options.
*
* @param	menu_id			The menu ID to modify, returned from ExtraMenu_Create()
*
* @noreturn
*/
native void ExtraMenu_NewPage(int menu_id);

/**
* @brief Displays a menu to a client.
*
* @param	client			Player to display the menu to
* @param	menu_id			The menu ID to display, returned from ExtraMenu_Create()
* @param	time			How long to display the menu for
*
* @return	True on success, false otherwise (possibly if menu is not available).
*/
native bool ExtraMenu_Display(int client, int menu_id, int time = MENU_TIME_FOREVER);



/**
* @brief Triggers whenever any menu item is selected, verify the ID with your known menus.
*
* @param	client			Player who selected something
* @param	menu_id			The menu ID that was selected
* @param	option			The selectable index someone pressed. When pressing "Exit" -1 is returned, when pressing "Previous" -2 is returned
* @param	value			The value they have selected from this entry, for the "MENU_SELECT_ONOFF" and "MENU_SELECT_ADD" types
*
* @noreturn
*/
forward void ExtraMenu_OnSelect(int client, int menu_id, int option, int value);

/**
 * 这个methodmap只是对native的包装，你仍然需要对ExtraMenu_OnSelect进行处理
 */

int ExtraMenuIndex[100];

methodmap ExtraMenu
{
	public ExtraMenu(bool back = false, char[] translation = "", bool button_usenum = false)
	{
		int menu_id = ExtraMenu_Create(back, translation, button_usenum);
		ExtraMenuIndex[menu_id] = 0;
		return view_as<ExtraMenu>(menu_id);
	}

	public bool __AddIntry(char[] entry, EXTRA_MENU_TYPE type, bool close = false, int default_value = 0, any add_value = 0, any add_min = -999999, any add_max = 999999)
	{
		return ExtraMenu_AddEntry(this._index, entry, type, close, default_value, add_value, add_min, add_max);
	}

	/**
	 * 添加一行文字， 不可选择
	 * 
	 * @param text 所显示的文字
	 */
	public bool AddEntry(char[] text){
		return this.__AddIntry(text, MENU_ENTRY);
	}
	public int AddEntryText(char[] text){
		if (!this.AddEntry(text)) return -1;
		return this._entryIndex;
	}
	public int AddEntryOnly(char[] text, bool close = false){
		if (!this.__AddIntry(text, MENU_SELECT_ONLY, close)) return -1;
		return this._entryIndex++;
	}
	public int AddEntrySwitch(char[] text, bool close = false, int default_value = 0){
		if (!this.__AddIntry(text, MENU_SELECT_ONOFF, close, default_value)) return -1;
		return this._entryIndex++;
	}
	public int AddEntryAdd(char[] text, bool close = false, int default_value = 0, any add_value = 0, any add_min = -999999, any add_max = 999999){
		if (!this.__AddIntry(text, MENU_SELECT_ADD, close, default_value, add_value, add_min, add_max)) return -1;
		return this._entryIndex++;
	}
	public int AddEntrySelect(char[] text, char[] select, bool close = false){
		if (!this.__AddIntry(text, MENU_SELECT_LIST,close)) return -1;
		this._AddOptions(select);
		return this._entryIndex++;
	}
	public void NewPage(){
		ExtraMenu_NewPage(this._index);
	}
	public bool _AddOptions(char[] entry)
	{
		ExtraMenu_AddOptions(view_as<int>(this), entry);
	}

	public bool Close()
	{
		return ExtraMenu_Delete(this._index);
	}

	public bool Show(int client, int int_time = MENU_TIME_FOREVER)
	{
		return ExtraMenu_Display(view_as<int>(this), client, int_time);
	}
	property int _entryIndex{
		public get(){ return ExtraMenuIndex[this._index];}
		public set(int value){ExtraMenuIndex[this._index] = value;}
	}

	property int _index{
        public get() { return view_as<int>(this); }
    }
}