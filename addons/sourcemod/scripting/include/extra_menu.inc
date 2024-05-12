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
	name ="extra_menu",
	file ="extra_menu.smx",
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
* @param	back			Gives a"Previous" option to the menu on the 1st page, useful to return to another menu
* @param	translation		Path to a translation file used for"ExtraMenu_AddEntry" entries or"" for no translation
* @param	buttons_nums	Menu movement type. False = W/A/S/D (freezes player). True = 1/2/3/4 (does not freeze player)
*
* @return	menu_id, the handle used to to add entries, display and delete the menu.
*/
native int ExtraMenu_Create(bool back = false, char[] translation ="", bool buttons_nums = false);

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
* @param	entry			The row string (can include"_OPT_" which will be replaced with [ ] and [X] for"MENU_SELECT_ONOFF" or the value for"MENU_SELECT_ADD" or"MENU_SELECT_LIST" types)
* @param	type			Type of entry (see the"MENU_*" variables)
* @param	close			Close the menu after selecting an option.
* @param	default_value	Default value for the"MENU_SELECT_ONOFF" and"MENU_SELECT_ADD" types.
* @param	add_value		Value to increment/decrement by when selecting (for use with"MENU_SELECT_ADD" type) (float values are supported)
* @param	add_min			Minimum value when using increment/decrement (for use with"MENU_SELECT_ADD" type) (float values are supported)
* @param	add_max			Maximum value when using increment/decrement (for use with"MENU_SELECT_ADD" type) (float values are supported)
*
* @return	True on success, false otherwise (possibly if menu is not available).
*/
native bool ExtraMenu_AddEntry(int menu_id, char[] entry, EXTRA_MENU_TYPE type, bool close = false, int default_value = 0, any add_value = 0, any add_min = -999999, any add_max = 999999);

/**
* @brief Adds a set of options to scroll through, for use with the"MENU_SELECT_LIST" type.
*
* @param	menu_id			The menu ID to modify, returned from ExtraMenu_Create()
* @param	entry			The string of options to scroll through, each entry separated by the"|" character
*
* @return	True on success, false otherwise (possibly if menu is not available).
*/
native bool ExtraMenu_AddOptions(int menu_id, char[] entry);

/**
* @brief Adds the next"ExtraMenu_AddEntry" data to a new page and creates the"Next Page" and"Previous Page" options.
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
* @param	option			The selectable index someone pressed. When pressing"Exit" -1 is returned, when pressing"Previous" -2 is returned
* @param	value			The value they have selected from this entry, for the"MENU_SELECT_ONOFF" and"MENU_SELECT_ADD" types
*
* @noreturn
*/
forward void ExtraMenu_OnSelect(int client, int menu_id, int option, int value);

/**
 * 这个methodmap只是对native的包装，你仍然需要对ExtraMenu_OnSelect进行处理
 */


/**
* @brief 创建一个菜单
*
* @param back 为第一页的菜单提供"上一页"选项，用于返回另一个菜单
* @param translation 用于"ExtraMenu_AddEntry"条目的翻译文件路径，无翻译则为""
* @param buttons_nums 菜单移动类型。False = W/A/S/D（阻止玩家移动）。True = 1/2/3/4 （不组织玩家移动）	
*
* @noreturn
*/

ArrayList extraMenuEntryIndex;
int extraMenuCount;
methodmap ExtraMenu
{
	/**
	* @brief 创建一个菜单
	*
	* @param back 为第一页的菜单提供"上一页"选项，用于返回另一个菜单
	* @param translation 用于"ExtraMenu_AddEntry"条目的翻译文件路径，无翻译则为""
	* @param buttons_nums 菜单移动类型。False = W/A/S/D（阻止玩家移动）。True = 1/2/3/4 （不组织玩家移动）	
	*
	* @noreturn
	*/
	public ExtraMenu(bool back = false, char[] translation ="", bool button_usenum = false)
	{
		if (extraMenuEntryIndex == INVALID_HANDLE) extraMenuEntryIndex = new ArrayList();
		int menu_id = ExtraMenu_Create(back, translation, button_usenum);
		if (extraMenuEntryIndex.Length <= menu_id) extraMenuEntryIndex.Resize(menu_id+1);
		extraMenuEntryIndex.Set(menu_id, 0);
		extraMenuCount++;
		return view_as<ExtraMenu>(menu_id);
	}
	/**
	* @brief 在菜单中添加一行条目，可以是不可选文本，也可以是可选选项。
	*
	* @param	entry			行字符串（可包含"_OPT_"，"MENU_SELECT_ONOFF"类型将用[ ]和[X]替换，"MENU_SELECT_ADD"或"MENU_SELECT_LIST"类型的值将用对应的值替换
	* @param	type			入口类型（参见"MENU_*"变量）
	* @param	close			在选择选项后关闭菜单。
	* @param	default_value	"MENU_SELECT_ONOFF"和"MENU_SELECT_ADD"类型的默认值。
	* @param	add_value		选择时递增/递减的值（与"MENU_SELECT_ADD"类型一起使用）（支持浮点数值）
	* @param	add_min			使用递增/递减时的最小值（与"MENU_SELECT_ADD"类型一起使用）（支持浮点数值）
	* @param	add_max			使用递增/递减时的最大值（与"MENU_SELECT_ADD"类型一起使用）（支持浮点数值）
	*
	* @return	成功时为 true，否则为 false（可能在菜单不可用时）。
	*/
	public bool __AddIntry(char[] entry, EXTRA_MENU_TYPE type, bool close = false, int default_value = 0, any add_value = 0, any add_min = -999999, any add_max = 999999)
	{
		return ExtraMenu_AddEntry(this._index, entry, type, close, default_value, add_value, add_min, add_max);
	}

	/**
	 * 添加一行不可选文字
	 * 
	 * @param text 	所显示的文字
	 * @return		成功时为 true，否则为 false（可能在菜单不可用时）。
	 */
	public bool AddEntry(char[] text){
		return this.__AddIntry(text, MENU_ENTRY);
	}
	/**
	 * 添加一行不可选文字，同AddEntry
	 * 
	 * @param text	所显示的文字
	 * @return		失败为 -1（可能在菜单不可用时）
	 */
	public int AddEntryText(char[] text){
		if (!this.AddEntry(text)) return -1;
		return this._entryIndex;
	}

	/**
	 * 添加一行可选文字，行为类似于按钮
	 * 
	 * @param text 	所显示的文字
	 * @param close 在选择选项后关闭菜单。
	 * @return		成功时为该可选项的index，否则为 -1（可能在菜单不可用时）。
	 */
	public int AddEntryOnly(char[] text, bool close = false){
		if (!this.__AddIntry(text, MENU_SELECT_ONLY, close)) return -1;
		return this._entryIndex++;
	}

	/**
	 * 添加一行可选文字，行为类似于开关
	 * 
	 * @param text 	所显示的文字, '_OPT_' 将被替换为 [ ] / [X]
	 * @param close 在选择选项后关闭菜单。
	 * @param default_value 默认值
	 * @return		成功时为该可选项的index，否则为 -1（可能在菜单不可用时）。
	 */
	public int AddEntrySwitch(char[] text, bool close = false, int default_value = 0){
		if (!this.__AddIntry(text, MENU_SELECT_ONOFF, close, default_value)) return -1;
		return this._entryIndex++;
	}

	/**
	 * 添加一行可选文字，控制对应变量的值（给定区间的变化范围）
	 * 
	 * @param text 	所显示的文字, '_OPT_' 将被替换为当前的value
	 * @param close 在选择选项后关闭菜单。
	 * @param default_value 默认值
	 * @param add_value 	每次调整的变化量
	 * @param add_min 		最小值
	 * @param add_max 		最大值
	 * @return		成功时为该可选项的index，否则为 -1（可能在菜单不可用时）。
	 */
	public int AddEntryAdd(char[] text, bool close = false, int default_value = 0, int add_value = 0, int add_min = -999999, int add_max = 999999){
		if (!this.__AddIntry(text, MENU_SELECT_ADD, close, default_value, add_value, add_min, add_max)) return -1;
		return this._entryIndex++;
	}

	/**
	 * 添加一行可选文字，控制对应变量的值（给定的选项）
	 * 
	 * @param text 	所显示的文字, '_OPT_' 将被替换为当前的value
	 * @param select 可选择的文本，使用'|'进行分隔
	 * @param close 在选择选项后关闭菜单。
	 * @return		成功时为该可选项的index，否则为 -1（可能在菜单不可用时）。
	 */
	public int AddEntrySelect(char[] text, char[] select, bool close = false){
		if (!this.__AddIntry(text, MENU_SELECT_LIST,close)) return -1;
		this._AddOptions(select);
		return this._entryIndex++;
	}

	/**
	 * @brief 将下一个"ExtraMenu_AddEntry"数据添加到新页面，并创建"下一页"和"上一页"选项。
	 * 
	 * @noreturn
	 */
	public void NewPage(){
		ExtraMenu_NewPage(this._index);
	}
	public bool _AddOptions(char[] entry)
	{
		ExtraMenu_AddOptions(view_as<int>(this), entry);
	}

	/**
	 * 	@brief 删除菜单。
	 * 
	 * @return	成功时为 true，否则为 false（可能在菜单不可用时）。
	 */
	public bool Close()
	{
		this._entryIndex = 0;
		if (--extraMenuCount <= 0) {
			CloseHandle(extraMenuEntryIndex);
			extraMenuEntryIndex = INVALID_HANDLE;
		}
		return ExtraMenu_Delete(this._index);
	}

	/**
	 * @brief 向客户端显示菜单。
	 * 
	 * @param client 要显示的客户端
	 * @param int_time 显示的时间
	 * @return	成功时为 true，否则为 false（可能在菜单不可用时）。
	 */
	public bool Show(int client, int int_time = MENU_TIME_FOREVER)
	{
		return ExtraMenu_Display(client, view_as<int>(this), int_time);
	}

	property int _entryIndex{
		public get(){ return extraMenuEntryIndex.Get(this._index);}
		public set(int value){extraMenuEntryIndex.Set(this._index, value);}
	}

	property int _index{
        public get() { return view_as<int>(this); }
    }
}