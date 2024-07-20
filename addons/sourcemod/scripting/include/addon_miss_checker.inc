#if defined _addon_miss_checker_included
 #endinput
#endif

#define _addon_miss_checker_included


/**
 * 添加一个Addon功能
 * 
 * @param feature_name          功能名称
 * @param feature_file          功能文件名
 * @param feature_description   功能描述
 * @param download_url          下载地址
 * @param use_valve_fs          是否使用Valve文件系统
 * @param valve_path_id         Valve文件系统路径
 * 
 * @return 功能id
 */
native int addAddonFeature(const char[] feature_name, const char[] feature_file, const char[] feature_description, const char[] download_url, bool use_valve_fs, const char[] valve_path_id);


/**
 * 检查客户端是否拥有某个Addon功能
 * 
 * @注意: 在OnClientPutInServer后6s左右检查完成
 * 
 * @param client                客户端id
 * @param feature_id            功能id
 * 
 * @return 是否拥有
 */
native bool isClientHasAddonFeature(int client, int feature_id);

public SharedPlugin __pl_filenetwork =
{
	name = "addon_miss_checker",
	file = "addon_miss_checker.smx",
	#if defined REQUIRE_PLUGIN
		required = 1,
	#else
		required = 0,
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_addon_miss_checker_SetNTVOptional()
{
	MarkNativeAsOptional("addAddonFeature");
}
#endif