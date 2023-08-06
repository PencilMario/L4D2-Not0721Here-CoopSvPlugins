#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdktools_functions>
#include <sdkhooks>
#include <adminmenu>

#define PLUGIN_VERSION "10.6"
#define CVAR_FLAGS FCVAR_SPONLY|FCVAR_NOTIFY

//主界面
#define 	ARMS 				1	//武器
#define	MELEE				2	//近战
#define	MELEE2				3	//三方图近战
#define 	PROPS 				4	//道具
#define	VARIA				5	//杂物选项
#define	SKINMENU			6   //人物皮肤厌恶菜单
#define	KILLMENU			7	//特殊项目菜单

//武器
#define	PISTOL				8	//手枪
#define	MAGNUM				9	//马格南手枪

#define	SMG					10	//冲锋枪
#define	SMGSILENCED		11	//消声冲锋枪
#define	MP5					12	//mp5冲锋枪

#define 	PUMPSHOTGUN1		13	//老式单发霰弹
#define 	PUMPSHOTGUN2		14	//新式单发霰弹
#define	AUTOSHOTGUN1		15	//老式连发霰弹
#define	AUTOSHOTGUN2		16	//新式连发霰弹

#define 	HUNTING1			17	//猎枪
#define	HUNTING2			18	//G3SG1狙击枪
#define	SNIPERSCOUT		19	//斯太尔小型狙击枪
#define	AWP					20	//麦格农大型狙击枪

#define 	M16					21	//m16突击步枪
#define	AK47				22	//ak47自动步枪
#define	SCAR				23	//三连发
#define	SG552				24	//sg552突击步枪
#define	GRENADELAUNCHER	25	//榴弹发射器
#define	M60					26	//M60机枪

//近战武器
#define	CROWBAR			27	//撬棍
#define	FIREAXE			28	//斧头
#define	KATANA				29	//武士刀
#define	CRICKETBAT			30	//板球棒
#define	BASEBALLBAT		31	//棒球棒
#define	FRYINGPAN			32	//平底锅
#define	GUITAR				33	//吉他
#define	TONFA				34	//警棍
#define	MACHETE			35	//砍刀
#define	KNIFE				36	//小刀
#define	CHAINSAW			37	//电锯
#define	SHOVEL				38	//铁铲
#define	PITCHFORK			39	//干草叉

//三方图近战
#define	LEONKNIFE			40	//里昂匕首
#define	BAJOROKU			41	//黑色吉他
#define	HAMMERROKU			42	//生化铁锤
#define	ZUKO				43	//火焰镰刀
#define	GUANDAO			44	//青龙偃月刀
#define	WULINMIJI			45	//武林秘笈
#define	DAGGERWATER		46	//水蓝短剑
#define	SCYTHEROKU			47	//死神镰刀
#define	BIGORONSWORD		48	//比戈龙剑
#define	DEKUSTICK			49	//树枝
#define	HAMMER				50	//巨锤
#define	HYLIANSHIELD		51	//海莲盾
#define	KICTHENKNIFE		52	//克钦小刀
#define	MASTERSWORD		53	//王者之剑
#define	MIRRORSHIELD		54	//镜之盾
#define	ROCKAXE			55	//登山斧
#define	SCUP				56	//杯子
#define	CAIDAO				57	//菜刀
#define	CHAIR				58	//椅子
#define	FINGER				59	//红手指
#define	MELEEJB			60	//JB近战
#define	ONION				61	//洋葱
#define	PINGPANG			62	//乒乓球拍
#define	WRENCH				63	//扳手
#define	FLAMETHROWER		64  //喷火枪

//道具投掷
#define	ADRENALINE			65	//肾上腺素
#define	PAINPILLS			66	//药丸
#define	FIRSTAIDKIT		67	//医疗包
#define	DEFIBRILLATOR		68	//电击器
#define	PIPEBOMB			69	//土制炸药
#define	VOMITJAR			70	//胆汁
#define	MOLOTOV			71	//燃烧瓶
#define	EXPLOSIVEPACK		72	//高爆弹药盒子
#define	INCENDIARYPACK	73	//燃烧弹药盒子
#define	UPGRADELASER		74	//红外线
#define	LASERPACK			75	//红外线盒子
#define 	AMMO				76	//弹药
#define 	HEALTH				77 // 生命值补充
#define	EXPLOSIVE			78	//高爆子弹
#define	INCENDIARY			79	//燃烧子弹

//杂物
#define GASCAN				80	//汽油桶
#define PROPANETANK			81	//煤气瓶
#define OXYGENTANK			82	//氧气瓶
#define FIREWORKCRATE		83	//烟花盒子
#define GNOME					84	//小矮人
#define AMMOSTACK				85	//弹药堆

//特殊项目
#define KILLCOMMON			86	//杀死小僵尸
#define KILLWITCH				87	//清除女巫
#define CREATEFIRE			88	//脚下点火
#define KILLWITCHS			89	//杀死女巫
#define KILLINFECTED			90	//杀死特感
#define CREATEBOMB			91	//脚下放炸弹
#define INFINITEAMMO			92	//无限补给
#define GODMODE				93	//无敌模式
#define SWARMMODE				94	//口水酸液
#define IMMUNEDAMAGE			95 //免疫友伤
#define WHITE					96 //白色（默认）
#define BLACK					97 //黑色
#define INVISIBLE				98 //透明
#define RED					99 //红色
#define GREEN					100 //绿色
#define BLUE					101 //蓝色
#define YELLOW				102 //黄色
#define PURPLE				103 //紫色
#define PINK					104 //粉红色
#define CYAN					105 //青色
#define GOLD					106 //金色
#define ICEBLUE				107 //冰蓝色

//武器的积分价值---------------------------------------------
//武器
Handle pistolmoney = INVALID_HANDLE;			//手枪
Handle magnummoney = INVALID_HANDLE;			//马格南手枪

Handle smgmoney = INVALID_HANDLE;				//冲锋枪
Handle smgsilencedmoney = INVALID_HANDLE;		//消声冲锋枪
Handle mp5money = INVALID_HANDLE;				

Handle pumpshotgun1money = INVALID_HANDLE;		//老式单发霰弹
Handle pumpshotgun2money = INVALID_HANDLE;		//新式单发霰弹
Handle autoshotgun1money = INVALID_HANDLE;		//老式连发霰弹
Handle autoshotgun2money = INVALID_HANDLE;		//新式连发霰弹

Handle hunting1money = INVALID_HANDLE;		//猎枪
Handle hunting2money = INVALID_HANDLE;		//G3SG1狙击枪
Handle sniperscoutmoney = INVALID_HANDLE;	//斯太尔小型狙击枪
Handle awpmoney = INVALID_HANDLE;			//麦格农大型狙击枪

Handle m16money = INVALID_HANDLE;			
Handle ak47money = INVALID_HANDLE;			
Handle scarmoney = INVALID_HANDLE;				//三连发
Handle grenadelaunchermoney = INVALID_HANDLE;			//榴弹发射器
Handle sg552money = INVALID_HANDLE;				//放大步枪
Handle m60money = INVALID_HANDLE;				//m60机枪

//近战武器
Handle crowbarmoney = INVALID_HANDLE;			//撬棍
Handle fireaxemoney = INVALID_HANDLE;			//斧头
Handle katanamoney = INVALID_HANDLE;			//武士刀
Handle cricketbatmoney = INVALID_HANDLE;		//板球棒
Handle baseballbatmoney = INVALID_HANDLE;		//棒球棒
Handle fryingpanmoney = INVALID_HANDLE;			//平底锅
Handle guitarmoney = INVALID_HANDLE;			//吉他
Handle tonfamoney = INVALID_HANDLE;				//警棍
Handle machetemoney = INVALID_HANDLE;			//砍刀
Handle chainsawmoney = INVALID_HANDLE;			//电锯
Handle knifemoney = INVALID_HANDLE;			//小刀
Handle shovelmoney = INVALID_HANDLE;			//铁铲
Handle pitchforkmoney = INVALID_HANDLE;			//干草叉

//三方图近战武器
Handle leonknifemoney = INVALID_HANDLE;	 //里昂匕首
Handle bajorokumoney = INVALID_HANDLE;		 //黑色吉他
Handle hammerrokumoney = INVALID_HANDLE;	 //生化铁锤
Handle zukomoney = INVALID_HANDLE;			 //火焰镰刀
Handle guandaomoney = INVALID_HANDLE;		 //青龙偃月刀
Handle wulinmijimoney = INVALID_HANDLE;	 //武林秘笈
Handle daggerwatermoney = INVALID_HANDLE;	 //水蓝短剑
Handle scytherokumoney = INVALID_HANDLE;	 //死神镰刀
Handle bigoronswordmoney = INVALID_HANDLE;	 //比戈龙剑
Handle dekustickmoney = INVALID_HANDLE;	 //树枝
Handle hammermoney = INVALID_HANDLE;		 //大铁锤
Handle hylianshieldmoney = INVALID_HANDLE;	 //海莲盾
Handle kicthenknifemoney = INVALID_HANDLE;	 //克钦小刀
Handle masterswordmoney = INVALID_HANDLE;   //王者之剑
Handle mirrorshieldmoney = INVALID_HANDLE;	 //镜之盾
Handle rockaxemoney = INVALID_HANDLE;		 //登山斧
Handle scupmoney = INVALID_HANDLE;			 //杯子
Handle caidaomoney = INVALID_HANDLE;		 //菜刀
Handle chairmoney = INVALID_HANDLE;			 //椅子
Handle fingermoney = INVALID_HANDLE;		 //红手指
Handle meleejbmoney = INVALID_HANDLE;		 //JB近战
Handle onionmoney = INVALID_HANDLE;			 //洋葱
Handle pingpangmoney = INVALID_HANDLE;		 //乒乓球拍
Handle wrenchmoney = INVALID_HANDLE;		 //扳手
Handle flamethrowermoney = INVALID_HANDLE;		 //喷火枪

//道具投掷
Handle adrenalinemoney = INVALID_HANDLE;		//肾上腺素
Handle painpillsmoney = INVALID_HANDLE;			//药丸
Handle firstaidkitmoney = INVALID_HANDLE;		//医疗包
Handle defibrillatormoney = INVALID_HANDLE;		//电击器
Handle pipebombmoney = INVALID_HANDLE;				//土制炸药
Handle vomitjarmoney = INVALID_HANDLE;			//胆汁
Handle molotovmoney = INVALID_HANDLE;			//燃烧瓶
Handle explosivepackmoney = INVALID_HANDLE;			//高爆弹药盒子
Handle incendiarypackmoney = INVALID_HANDLE;		//燃烧弹药盒子
Handle upgradelasermoney = INVALID_HANDLE;			//红外线
Handle ammomoney = INVALID_HANDLE;				//弹药
Handle healthmoney = INVALID_HANDLE;				//生命值补充
Handle explosivemoney = INVALID_HANDLE;			//高爆子弹
Handle incendiarymoney = INVALID_HANDLE;		//燃烧子弹
Handle laserpackmoney = INVALID_HANDLE;			//红外线盒子

//杂物
Handle gascanmoney = INVALID_HANDLE;			//汽油桶
Handle propanetankmoney = INVALID_HANDLE;			//煤气瓶
Handle oxygentankmoney = INVALID_HANDLE;		//氧气瓶
Handle fireworkcratemoney = INVALID_HANDLE;			//烟花盒子
Handle gnomemoney = INVALID_HANDLE;				//小矮人
Handle ammostackmoney = INVALID_HANDLE;				//弹药堆

//特殊项目购买
Handle killcommonmoney = INVALID_HANDLE;			//杀死小僵尸
Handle killwitchmoney = INVALID_HANDLE;				//清除女巫
Handle createfiremoney = INVALID_HANDLE;				//脚下点火
Handle killwitchesmoney = INVALID_HANDLE;				//杀死女巫
Handle killinfectedmoney = INVALID_HANDLE;				//杀死特感
Handle createbombmoney = INVALID_HANDLE;				//脚下放炸弹
Handle infiniteammomoney = INVALID_HANDLE;				//无限补给
Handle godmodemoney = INVALID_HANDLE;				//无敌模式
Handle swarmmodemoney = INVALID_HANDLE;				//抵抗口水酸液
Handle immunedamagemoney = INVALID_HANDLE;				//免疫友伤
Handle skinblackmoney = INVALID_HANDLE;				//黑色皮肤
Handle skininvisiblemoney = INVALID_HANDLE;			//透明皮肤
Handle skinredmoney = INVALID_HANDLE;				    //红色皮肤
Handle skingreenmoney = INVALID_HANDLE;				//绿色皮肤
Handle skinbluemoney = INVALID_HANDLE;					//蓝色皮肤
Handle skinyellowmoney = INVALID_HANDLE;				//黄色皮肤
Handle skinpurplemoney = INVALID_HANDLE;				//紫色皮肤
Handle skinpinkmoney = INVALID_HANDLE;					//粉红色皮肤
Handle skincyanmoney = INVALID_HANDLE;					//青色皮肤
Handle skingoldmoney = INVALID_HANDLE;					//金色皮肤
Handle skinicebluemoney = INVALID_HANDLE;				//冰蓝色皮肤

int GiveNumber;			//用于给予积分方法的临时变量
int Integral[MAXPLAYERS+1];	//积分
Handle MaxIntegral = INVALID_HANDLE;			//积分上限
int KillZombies[MAXPLAYERS+1];	//杀僵尸数量
Handle KillZombiesIntegral = INVALID_HANDLE;	//杀僵尸所得的积分
Handle MaxKillZombies = INVALID_HANDLE;		//杀多少僵尸获得积分
Handle WarningIntegral = INVALID_HANDLE;	//多少提示

Handle SmokerIntegral = INVALID_HANDLE;
Handle BoomerIntegral = INVALID_HANDLE;
Handle HunterIntegral = INVALID_HANDLE;
Handle SpitterIntegral = INVALID_HANDLE;
Handle JockeyIntegral = INVALID_HANDLE;
Handle ChargerIntegral = INVALID_HANDLE;
Handle TankIntegral = INVALID_HANDLE;
Handle TankKillIntegral = INVALID_HANDLE;
Handle WitchIntegral = INVALID_HANDLE;
Handle WitchKillIntegral = INVALID_HANDLE;

bool Rescueflag;	//结局开关

int InfiniteAmmo[MAXPLAYERS+1]; //player can Infinite Ammo
int GodMode[MAXPLAYERS+1];
int SwarmMode[MAXPLAYERS+1];
int WitchDamage[MAXPLAYERS+1];
int ImmuneMode[MAXPLAYERS+1];
int Throwing[MAXPLAYERS+1];

int g_iClipSize_RifleM60;
int g_iClipSize_GrenadeLauncher;
forward void OnGetWeaponsInfo(int pThis, const char[] classname);
native void InfoEditor_GetString(int pThis, const char[] keyname, char[] dest, int destLen);

//插件启动时函数
public void OnPluginStart()
{
	LogAction(0, -1, "验证通过，欢迎使用.");

	MaxIntegral=CreateConVar("sm_integralshop_MaxIntegral","100","积分上限.",CVAR_FLAGS, true, 0.0, true, 99999.0);

	MaxKillZombies	=	CreateConVar("sm_integralshop_MaxKillZombies","26","杀多少僵尸能获得积分奖励.",CVAR_FLAGS);
	KillZombiesIntegral	=	CreateConVar("sm_integralshop_KillZombiesIntegral","2","杀足够僵尸获得的积分.",CVAR_FLAGS);
	WarningIntegral	=	CreateConVar("sm_integralshop_WarningIntegral","2.0","积分达到多少预警(0.5就是50%).",CVAR_FLAGS);
	
	SmokerIntegral	=	CreateConVar("sm_integralshop_SmokerIntegral","5","杀Smoker获得的积分.",CVAR_FLAGS);
	BoomerIntegral	=	CreateConVar("sm_integralshop_BoomerIntegral","5","杀Boomer获得的积分.",CVAR_FLAGS);
	HunterIntegral	=	CreateConVar("sm_integralshop_HunterIntegral","5","杀Hunter获得的积分.",CVAR_FLAGS);
	SpitterIntegral	=	CreateConVar("sm_integralshop_SpitterIntegral","5","杀Spitter获得的积分.",CVAR_FLAGS);
	JockeyIntegral	=	CreateConVar("sm_integralshop_JockeyIntegral","5","杀Jockey获得的积分.",CVAR_FLAGS);
	ChargerIntegral	=	CreateConVar("sm_integralshop_ChargerIntegral","5","杀Charger获得的积分.",CVAR_FLAGS);
	TankKillIntegral	=	CreateConVar("sm_integralshop_TankKillIntegral","100","给予坦克最后一击的人获得的积分奖励.",CVAR_FLAGS);
	TankIntegral	=	CreateConVar("sm_integralshop_TankIntegral","50","坦克死亡全队活者的幸存者获得的积分.",CVAR_FLAGS);
	WitchIntegral	=	CreateConVar("sm_integralshop_WitchIntegral","50","女巫死亡全队活者的幸存者获得的积分.",CVAR_FLAGS);
	WitchKillIntegral	=	CreateConVar("sm_integralshop_WitchKillIntegral","100","给予女巫克最后一击的人获得的积分奖励.",CVAR_FLAGS);	

	pistolmoney	=	CreateConVar("sm_integralshop_pistolmoney","100","手枪的价格.",CVAR_FLAGS);
	magnummoney	=	CreateConVar("sm_integralshop_magnummoney","100","马格南手枪的价格.",CVAR_FLAGS);
	smgsilencedmoney	=	CreateConVar("sm_integralshop_smgsilencedmoney","20","消声冲锋枪的价格.",CVAR_FLAGS);
	smgmoney	=	CreateConVar("sm_integralshop_smgmoney","20","冲锋枪的价格.",CVAR_FLAGS);
	mp5money	=	CreateConVar("sm_integralshop_mp5money","20","MP5冲锋枪的价格.",CVAR_FLAGS);
	pumpshotgun1money	=	CreateConVar("sm_integralshop_pumpshotgun1money","20","老式单发霰弹枪的价格.",CVAR_FLAGS);
	autoshotgun1money	=	CreateConVar("sm_integralshop_autoshotgun1money","20","老式连发霰弹枪的价格.",CVAR_FLAGS);
	
	pumpshotgun2money	=	CreateConVar("sm_integralshop_pumpshotgun2money","100","新式单发霰弹枪的价格.",CVAR_FLAGS);
	autoshotgun2money	=	CreateConVar("sm_integralshop_autoshotgun2money","100","新式连发霰弹枪的价格.",CVAR_FLAGS);
	m16money	=	CreateConVar("sm_integralshop_m16money","100","M16步枪的价格.",CVAR_FLAGS);
	ak47money	=	CreateConVar("sm_integralshop_ak47money","100","AK47步枪的价格.",CVAR_FLAGS);
	scarmoney	=	CreateConVar("sm_integralshop_scarmoney","100","三连发步枪的价格.",CVAR_FLAGS);
	sg552money	=	CreateConVar("sm_integralshop_sg552money","100","放大步枪的价格.",CVAR_FLAGS);
	m60money	=	CreateConVar("sm_integralshop_m60money","100","m60机枪的价格.",CVAR_FLAGS);	
	
	hunting1money	=	CreateConVar("sm_integralshop_hunting1money","100","狩猎狙击枪的价格.",CVAR_FLAGS);
	sniperscoutmoney	=	CreateConVar("sm_integralshop_sniperscoutmoney","75","Scout小型狙击枪的价格.",CVAR_FLAGS);
	hunting2money	=	CreateConVar("sm_integralshop_hunting2money","100","军事狙击枪的价格.",CVAR_FLAGS);
	awpmoney	=	CreateConVar("sm_integralshop_awpmoney","100","AWP狙击枪的价格.",CVAR_FLAGS);
	grenadelaunchermoney	=	CreateConVar("sm_integralshop_grenadelaunchermoney","1000","榴弹发射器的价格.",CVAR_FLAGS);

	crowbarmoney	=	CreateConVar("sm_integralshop_crowbarmoney","100","撬棍的价格.",CVAR_FLAGS);
	fireaxemoney	=	CreateConVar("sm_integralshop_fireaxemoney","30","斧头的价格.",CVAR_FLAGS);
	katanamoney	=	CreateConVar("sm_integralshop_katanamoney","50","武士刀的价格.",CVAR_FLAGS);
	cricketbatmoney	=	CreateConVar("sm_integralshop_cricketbatmoney","100","板球棒的价格.",CVAR_FLAGS);
	baseballbatmoney	=	CreateConVar("sm_integralshop_baseballbatmoney","100","棒球棒的价格.",CVAR_FLAGS);
	fryingpanmoney	=	CreateConVar("sm_integralshop_fryingpanmoney","100","平底锅的价格.",CVAR_FLAGS);
	guitarmoney	=	CreateConVar("sm_integralshop_guitarmoney","100","电吉他的价格.",CVAR_FLAGS);
	tonfamoney	=	CreateConVar("sm_integralshop_tonfamoney","100","警棍的价格.",CVAR_FLAGS);
	machetemoney	=	CreateConVar("sm_integralshop_machetemoney","50","砍刀的价格.",CVAR_FLAGS);
	chainsawmoney	=	CreateConVar("sm_integralshop_chainsawmoney","50","电锯的价格.",CVAR_FLAGS);
	knifemoney	=	CreateConVar("sm_integralshop_knifemoney","50","小刀的价格.",CVAR_FLAGS);	
	shovelmoney	=	CreateConVar("sm_integralshop_shovelmoney","50","铁铲的价格.",CVAR_FLAGS);
	pitchforkmoney	=	CreateConVar("sm_integralshop_pitchforkmoney","50","干草叉的价格.",CVAR_FLAGS);

	leonknifemoney	=	CreateConVar("sm_integralshop_leonknifemoney","5","里昂匕首的价格.",CVAR_FLAGS);
	bajorokumoney	=	CreateConVar("sm_integralshop_bajorokumoney","3","黑色吉他的价格.",CVAR_FLAGS);
	hammerrokumoney	=	CreateConVar("sm_integralshop_hammerrokumoney","5","生化铁锤的价格.",CVAR_FLAGS);
	zukomoney	=	CreateConVar("sm_integralshop_zukomoney","5","火焰镰刀的价格.",CVAR_FLAGS);
	guandaomoney	=	CreateConVar("sm_integralshop_guandaomoney","5","青龙偃月刀的价格.",CVAR_FLAGS);
	wulinmijimoney	=	CreateConVar("sm_integralshop_wulinmijimoney","5","武林秘笈的价格.",CVAR_FLAGS);
	daggerwatermoney	=	CreateConVar("sm_integralshop_daggerwatermoney","5","水蓝短剑的价格.",CVAR_FLAGS);
	scytherokumoney	=	CreateConVar("sm_integralshop_scytherokumoney","5","死神镰刀的价格.",CVAR_FLAGS);
	bigoronswordmoney	=	CreateConVar("sm_integralshop_bigoronswordmoney","5","比戈龙剑的价格.",CVAR_FLAGS);
	dekustickmoney	=	CreateConVar("sm_integralshop_dekustickmoney","5","树枝的价格.",CVAR_FLAGS);
	hammermoney	=	CreateConVar("sm_integralshop_hammermoney","5","大铁锤的价格.",CVAR_FLAGS);	
	hylianshieldmoney	=	CreateConVar("sm_integralshop_hylianshieldmoney","5","海莲盾的价格.",CVAR_FLAGS);
	kicthenknifemoney	=	CreateConVar("sm_integralshop_kicthenknifemoney","5","克钦小刀的价格.",CVAR_FLAGS);	
	masterswordmoney	=	CreateConVar("sm_integralshop_masterswordmoney","5","王者之剑的价格.",CVAR_FLAGS);
	mirrorshieldmoney	=	CreateConVar("sm_integralshop_mirrorshieldmoney","5","镜之盾的价格.",CVAR_FLAGS);
	rockaxemoney	=	CreateConVar("sm_integralshop_rockaxemoney","5","登山斧的价格.",CVAR_FLAGS);
	scupmoney	=	CreateConVar("sm_integralshop_scupmoney","5","杯子的价格.",CVAR_FLAGS);
	caidaomoney	=	CreateConVar("sm_integralshop_caidaomoney","5","菜刀的价格.",CVAR_FLAGS);
	chairmoney	=	CreateConVar("sm_integralshop_chairmoney","5","椅子的价格.",CVAR_FLAGS);
	fingermoney	=	CreateConVar("sm_integralshop_fingermoney","5","红手指的价格.",CVAR_FLAGS);
	meleejbmoney	=	CreateConVar("sm_integralshop_meleejbmoney","5","JB近战的价格.",CVAR_FLAGS);
	onionmoney	=	CreateConVar("sm_integralshop_onionmoney","5","洋葱的价格.",CVAR_FLAGS);	
	pingpangmoney	=	CreateConVar("sm_integralshop_pingpangmoney","5","乒乓球拍的价格.",CVAR_FLAGS);
	wrenchmoney	=	CreateConVar("sm_integralshop_wrenchmoney","5","扳手的价格.",CVAR_FLAGS);
	flamethrowermoney	=	CreateConVar("sm_integralshop_flamethrowermoney","5","喷火枪的价格.",CVAR_FLAGS);

	painpillsmoney	=	CreateConVar("sm_integralshop_painpillsmoney","100","止痛药的价格.",CVAR_FLAGS);
	adrenalinemoney	=	CreateConVar("sm_integralshop_adrenalinemoney","100","肾上腺素的价格.",CVAR_FLAGS);
	firstaidkitmoney	=	CreateConVar("sm_integralshop_firstaidkitmoney","100","医疗包的价格.",CVAR_FLAGS);
	defibrillatormoney	=	CreateConVar("sm_integralshop_defibrillatormoney","100","电击器的价格.",CVAR_FLAGS);
	pipebombmoney	=	CreateConVar("sm_integralshop_bombmoney","50","土制炸药的价格.",CVAR_FLAGS);
	vomitjarmoney	=	CreateConVar("sm_integralshop_vomitjarmoney","50","胆汁的价格.",CVAR_FLAGS);
	molotovmoney	=	CreateConVar("sm_integralshop_molotovmoney","50","燃烧瓶的价格.",CVAR_FLAGS);
	explosivepackmoney	=	CreateConVar("sm_integralshop_explosivepackmoney","100","高爆弹药盒子的价格.",CVAR_FLAGS);
	incendiarypackmoney	=	CreateConVar("sm_integralshop_incendiarypackmoney","100","燃烧弹药盒子的价格.",CVAR_FLAGS);
	upgradelasermoney	=	CreateConVar("sm_integralshop_upgradelasermoney","100","红外线的价格.",CVAR_FLAGS);
	ammomoney	=	CreateConVar("sm_integralshop_ammomoney","100","弹药的价格",CVAR_FLAGS);
	healthmoney = CreateConVar("sm_integralshop_healthmoney","100","补充生命的价格",CVAR_FLAGS);
	explosivemoney	=	CreateConVar("sm_integralshop_explosivemoney","100","高爆子弹箱的价格.",CVAR_FLAGS);
	incendiarymoney	=	CreateConVar("sm_integralshop_incendiarymoney","100","燃烧子弹箱的价格.",CVAR_FLAGS);
	laserpackmoney	=	CreateConVar("sm_integralshop_upgrademoney","100","红外线盒子的价格.",CVAR_FLAGS);

	gascanmoney	=	CreateConVar("sm_integralshop_gascanmoney","50","汽油桶的价格.",CVAR_FLAGS);
	propanetankmoney	=	CreateConVar("sm_integralshop_propanetankmoney","50","煤气瓶的价格.",CVAR_FLAGS);
	oxygentankmoney	=	CreateConVar("sm_integralshop_oxygentankmoney","50","氧气瓶的价格.",CVAR_FLAGS);
	fireworkcratemoney	=	CreateConVar("sm_integralshop_fireworkmoney","50","烟花盒子的价格.",CVAR_FLAGS);
	gnomemoney	=	CreateConVar("sm_integralshop_gnomemoney","50","小矮人的价格.",CVAR_FLAGS);
	ammostackmoney	=	CreateConVar("sm_integralshop_ammostackmoney","20","弹药堆的价格",CVAR_FLAGS);

	killcommonmoney	=	CreateConVar("sm_integralshop_killcommonmoney","100","杀死全部小僵尸需要多少积分.",CVAR_FLAGS);
	killwitchmoney	=	CreateConVar("sm_integralshop_killwitchmoney","100","清除地图上全部女巫需要多少积分.",CVAR_FLAGS);
	createfiremoney	=	CreateConVar("sm_integralshop_createfiremoney","100","脚下点火需要多少积分",CVAR_FLAGS);
	killwitchesmoney	=	CreateConVar("sm_integralshop_killwitchesmoney","100","杀死全部女巫需要多少积分.",CVAR_FLAGS);
	killinfectedmoney	=	CreateConVar("sm_integralshop_killnfectedmoney","100","杀死全部特感需要多少积分.",CVAR_FLAGS);
	createbombmoney	=	CreateConVar("sm_integralshop_createbombmoney","100","脚下放炸弹需要多少积分",CVAR_FLAGS);
	infiniteammomoney	=	CreateConVar("sm_integralshop_infiniteammomoney","100","无限补给需要多少积分",CVAR_FLAGS);
	godmodemoney	=	CreateConVar("sm_integralshop_godmodemoney","100","无敌模式需要多少积分",CVAR_FLAGS);
	swarmmodemoney	=	CreateConVar("sm_integralshop_swarmmodemoney","100","抵抗力需要多少积分",CVAR_FLAGS);
	immunedamagemoney	=	CreateConVar("sm_integralshop_immunedamagemoney","1","免疫友伤需要多少积分",CVAR_FLAGS);
	skinblackmoney	=	CreateConVar("sm_integralshop_skinblackmoney","2","黑色皮肤需要多少积分",CVAR_FLAGS);
	skininvisiblemoney	=	CreateConVar("sm_integralshop_skininvisiblemoney","2","透明皮肤需要多少积分",CVAR_FLAGS);
	skinredmoney	=	CreateConVar("sm_integralshop_skinredmoney","2","红色皮肤需要多少积分",CVAR_FLAGS);
	skingreenmoney	=	CreateConVar("sm_integralshop_skingreenmoney","2","绿色皮肤需要多少积分",CVAR_FLAGS);
	skinbluemoney	=	CreateConVar("sm_integralshop_skinbluemoney","2","蓝色皮肤需要多少积分",CVAR_FLAGS);
	skinyellowmoney	=	CreateConVar("sm_integralshop_skinyellowmoney","2","黄色皮肤需要多少积分",CVAR_FLAGS);
	skinpurplemoney	=	CreateConVar("sm_integralshop_skinpurplemoney","2","紫色皮肤需要多少积分",CVAR_FLAGS);
	skinpinkmoney	=	CreateConVar("sm_integralshop_skinpinkmoney","2","粉红色皮肤需要多少积分",CVAR_FLAGS);
	skincyanmoney	=	CreateConVar("sm_integralshop_skincyanmoney","2","青色皮肤需要多少积分",CVAR_FLAGS);
	skingoldmoney	=	CreateConVar("sm_integralshop_skingoldmoney","2","金色皮肤需要多少积分",CVAR_FLAGS);
	skinicebluemoney	=	CreateConVar("sm_integralshop_skinicebluemoney","2","冰蓝色皮肤需要多少积分",CVAR_FLAGS);

	RegConsoleCmd("sm_b",ShowMenu,"购买主菜单");
	RegConsoleCmd("sm_buy",ShowMenu,"购买主菜单");
	RegAdminCmd("sm_jfall",GiveAllIntegral,ADMFLAG_KICK,"给予全体积分");
	
	HookEvent("infected_death",ZombiesDead);
	HookEvent("finale_vehicle_leaving", evtFinaleVehicleLeaving);	//结局车辆离开
	
	HookEvent("player_death", PlayerDeath);	//特感死亡
	HookEvent("tank_killed", TankKill);	//坦克死亡	
	HookEvent("witch_killed", Event_Witch_Death);
	//HookEvent("round_start", EventGiveIntegral, EventHookMode_Post); // 延时给积分
	HookEvent("round_start", Event_RoundStart, EventHookMode_Post);
	HookEvent("weapon_fire", Event_WeaponFire);
	HookEvent("weapon_drop", Event_WeaponDrop);
	HookEvent("heal_success", Event_HealSuccess);
	HookEvent("pills_used", Event_PillsUsed);
	HookEvent("adrenaline_used", Event_AdrenalineUsed);
	HookEvent("defibrillator_used", Event_DefibrillatorUsed);
	AutoExecConfig(true, "IntegralShop_v10.6"); // 必须放在这里
}

public void EventGiveIntegral(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(12.0, JFALLDelay);
}

public Action JFALLDelay(Handle timer)
{
	GiveIntegral();
}

void GiveIntegral()
{	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i)==2) FakeClientCommand(i, "sm_jfall 100");
	}
}

public void OnClientDisconnect(int client)
{
	InfiniteAmmo[client] = false;
	GodMode[client] = false;
	Throwing[client] = 0;
	SwarmMode[client] = false;
	WitchDamage[client] = false;
	ImmuneMode[client] = false;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamageGod);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamageSwarm);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamageWitch);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamageImmune);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamageChainsaw);
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	for( int i = 1; i <= MaxClients; i++ ) 
	{
		InfiniteAmmo[i] = false;
		GodMode[i] = false;
		Throwing[i] = 0;
		SwarmMode[i] = false;
		WitchDamage[i] = false;
		ImmuneMode[i] = false;
	}
}

//地图启动事件
public void OnMapStart()
{
	Rescueflag = true;
	PrecacheModel("models/props_junk/gascan001a.mdl", true);
	PrecacheModel("models/props_junk/propanecanister001a.mdl", true);
}

//僵尸死亡
public Action ZombiesDead(Event event, const char[] event_name, bool dontBroadcast)
{
	if(Rescueflag)
	{
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		
		if(attacker <= 0) 
		{
			return Plugin_Continue;
		}
		
		if(IsClientInGame(attacker) && GetClientTeam(attacker) == 2)
		{
			if(KillZombies[attacker] >= GetConVarInt(MaxKillZombies))
			{
				Integral[attacker] += GetConVarInt(KillZombiesIntegral);
				PrintToChat(attacker,"\x03击杀了\x04%d\x03个僵尸,收获\x04%d\x03积分,余额\x04%d\x03积分",GetConVarInt(MaxKillZombies),GetConVarInt(KillZombiesIntegral),Integral[attacker]);
				KillZombies[attacker] = 0;
				if(Integral[attacker] > GetConVarInt(MaxIntegral))
				{
					PrintToChat(attacker,"\x05你的\x04积分已满\x05,请注意!");
				}
				else if(Integral[attacker]/GetConVarFloat(MaxIntegral)>GetConVarFloat(WarningIntegral))
				{
					PrintToChat(attacker,"\x03你的积分已上限\x04 %0.0f%% \x03请尽快使用!",GetConVarFloat(WarningIntegral)*100);
				}
			}
			else
			{
				KillZombies[attacker] ++;
			}
			if(Integral[attacker] > GetConVarInt(MaxIntegral))
			{	
				Integral[attacker] = GetConVarInt(MaxIntegral);	
			}
		}
	}
	
	return Plugin_Continue;
	
}

public Action PlayerDeath(Event event, const char[] event_name, bool dontBroadcast)
{
	if(Rescueflag)
	{
		int victim = GetClientOfUserId(GetEventInt(event, "userid"));
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		
		if(attacker <= 0 || victim <= 0 || GetClientTeam(victim) != 3 || !IsValidEntity(victim)) 
		{
			return Plugin_Continue;
		}
		
		
		if(IsValidClient(attacker))
		{
			if(GetClientTeam(attacker) == 2)
			{
				if(!IsFakeClient(attacker))
				{
					switch (GetEntProp(victim, Prop_Send, "m_zombieClass"))
					{
						case 1:
						{
							Integral[attacker]+=GetConVarInt(SmokerIntegral);
							PrintToChat(attacker,"\x03你击杀了\x04Smoker\x03,收获\x04%d\x03积分,余额\x04%d\x03积分",GetConVarInt(SmokerIntegral),Integral[attacker]);
							if(Integral[attacker] > GetConVarInt(MaxIntegral))
							{
								PrintToChat(attacker,"\x05你的\x04积分已满\x05,请注意!");
							}
							else if(Integral[attacker]/GetConVarFloat(MaxIntegral)>GetConVarFloat(WarningIntegral))
							{
								PrintToChat(attacker,"\x03你的积分已上限\x04 %0.0f%% \x03请尽快使用!",GetConVarFloat(WarningIntegral)*100);
							}
						}
						case 2:
						{
							Integral[attacker]+=GetConVarInt(BoomerIntegral);
							PrintToChat(attacker,"\x03你击杀了\x04Boomer\x03,收获\x04%d\x03积分,余额\x04%d\x03积分",GetConVarInt(BoomerIntegral),Integral[attacker]);
							if(Integral[attacker] > GetConVarInt(MaxIntegral))
							{
								PrintToChat(attacker,"\x05你的\x04积分已满\x05,请注意!");
							}
							else if(Integral[attacker]/GetConVarFloat(MaxIntegral)>GetConVarFloat(WarningIntegral))
							{
								PrintToChat(attacker,"\x03你的积分已上限\x04 %0.0f%% \x03请尽快使用!",GetConVarFloat(WarningIntegral)*100);
							}
						}
						case 3:
						{
							Integral[attacker]+=GetConVarInt(HunterIntegral);	//小偷
							PrintToChat(attacker,"\x03你击杀了\x04Hunter\x03,收获\x04%d\x03积分,余额\x04%d\x03积分",GetConVarInt(HunterIntegral),Integral[attacker]);
							if(Integral[attacker] > GetConVarInt(MaxIntegral))
							{
								PrintToChat(attacker,"\x05你的\x04积分已满\x05,请注意!");
							}
							else if(Integral[attacker]/GetConVarFloat(MaxIntegral)>GetConVarFloat(WarningIntegral))
							{
								PrintToChat(attacker,"\x03你的积分已上限\x04 %0.0f%% \x03请尽快使用!",GetConVarFloat(WarningIntegral)*100);
							}
						}
						case 4:
						{
							Integral[attacker]+=GetConVarInt(SpitterIntegral);//毒液
							PrintToChat(attacker,"\x03你击杀了\x04Spitter\x03,收获\x04%d\x03积分,余额\x04%d\x03积分",GetConVarInt(SpitterIntegral),Integral[attacker]);
							if(Integral[attacker] > GetConVarInt(MaxIntegral))
							{
								PrintToChat(attacker,"\x05你的\x04积分已满\x05,请注意!");
							}
							else if(Integral[attacker]/GetConVarFloat(MaxIntegral)>GetConVarFloat(WarningIntegral))
							{
								PrintToChat(attacker,"\x03你的积分已上限\x04 %0.0f%% \x03请尽快使用!",GetConVarFloat(WarningIntegral)*100);
							}
						}
						case 5:
						{
							Integral[attacker]+=GetConVarInt(JockeyIntegral);	//猴子
							PrintToChat(attacker,"\x03你击杀了\x04Jockey\x03,收获\x04%d\x03积分,余额\x04%d\x03积分",GetConVarInt(JockeyIntegral),Integral[attacker]);
							if(Integral[attacker] > GetConVarInt(MaxIntegral))
							{
								PrintToChat(attacker,"\x05你的\x04积分已满\x05,请注意!");
							}
							else if(Integral[attacker]/GetConVarFloat(MaxIntegral)>GetConVarFloat(WarningIntegral))
							{
								PrintToChat(attacker,"\x03你的积分已上限\x04 %0.0f%% \x03请尽快使用!",GetConVarFloat(WarningIntegral)*100);
							}
						}
						case 6:
						{
							Integral[attacker]+=GetConVarInt(ChargerIntegral);
							PrintToChat(attacker,"\x03你击杀了\x04Charger\x03,收获\x04%d\x03积分,余额\x04%d\x03积分",GetConVarInt(ChargerIntegral),Integral[attacker]);
							if(Integral[attacker] > GetConVarInt(MaxIntegral))
							{
								PrintToChat(attacker,"\x05你的\x04积分已满\x05,请注意!");
							}
							else if(Integral[attacker]/GetConVarFloat(MaxIntegral)>GetConVarFloat(WarningIntegral))
							{
								PrintToChat(attacker,"\x03你的积分已上限\x04 %0.0f%% \x03请尽快使用!",GetConVarFloat(WarningIntegral)*100);
							}
						}
					}					
					if(Integral[attacker] > GetConVarInt(MaxIntegral))
					{	
						Integral[attacker] = GetConVarInt(MaxIntegral);	
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public void Event_Witch_Death(Event event, const char[] name, bool dontBroadcast)
{
	if(Rescueflag)
	{
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		
		for(int i=1; i <= MaxClients; i++)
		{
			if(IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == 2 && !IsFakeClient(i) && !GetEntProp(i, Prop_Send, "m_lifeState"))
			{
				if(i!=attacker)
				{
					Integral[i]+=GetConVarInt(WitchIntegral);
					PrintToChat(i,"\x04女巫\x03死亡,活者的幸存者收获\x04%d\x03积分,余额\x04%d\x03积分",GetConVarInt(WitchIntegral),Integral[i]);				//女巫
					Integral[i]+=GetConVarInt(WitchIntegral);
					if(Integral[i] > GetConVarInt(MaxIntegral))
					{
						PrintToChat(i,"\x05你的\x04积分已满\x05,请注意!");
					}
					else if(Integral[i]/GetConVarFloat(MaxIntegral)>GetConVarFloat(WarningIntegral))
					{
						PrintToChat(i,"\x03你的积分已上限\x04 %0.0f%% \x03请尽快使用!",GetConVarFloat(WarningIntegral)*100);
					}
				}
				else if(i==attacker)
				{
					Integral[i]+=GetConVarInt(WitchKillIntegral);
					PrintToChat(i,"\x03你给予了\x04女巫\x03致命一击,额外收获\x04%d\x03积分,余额\x04%d\x03积分",GetConVarInt(WitchKillIntegral),Integral[i]);				//女巫
					if(Integral[i] > GetConVarInt(MaxIntegral))
					{
						PrintToChat(i,"\x05你的\x04积分已满\x05,请注意!");
					}
					else if(Integral[i]/GetConVarFloat(MaxIntegral)>GetConVarFloat(WarningIntegral))
					{
						PrintToChat(i,"\x03你的积分已上限\x04 %0.0f%% \x03请尽快使用!",GetConVarFloat(WarningIntegral)*100);
					}
				}
			}
			if(Integral[i] > GetConVarInt(MaxIntegral))
			{	
				Integral[i] = GetConVarInt(MaxIntegral);
			}
		}
	}
}

public void TankKill(Event event, const char[] event_name, bool dontBroadcast)
{
	if(Rescueflag)
	{
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		
		for(int i=1; i <= MaxClients; i++)
		{
			if(IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == 2 && !IsFakeClient(i) && !GetEntProp(i, Prop_Send, "m_lifeState"))
			{
				if(i!=attacker)
				{
					Integral[i]+=GetConVarInt(TankIntegral);
					PrintToChat(i,"\x04Tank\x03死亡,活者的幸存者收获\x04%d\x03积分,余额\x04%d\x03积分",GetConVarInt(TankIntegral),Integral[i]);				//坦克
					if(Integral[i] > GetConVarInt(MaxIntegral))
					{
						PrintToChat(i,"\x05你的\x04积分已满\x05,请注意!");
					}
					else if(Integral[i]/GetConVarFloat(MaxIntegral)>GetConVarFloat(WarningIntegral))
					{
						PrintToChat(i,"\x03你的积分已上限\x04 %0.0f%% \x03请尽快使用!",GetConVarFloat(WarningIntegral)*100);
					}
				}
				else if(i==attacker)
				{
					Integral[i]+=GetConVarInt(TankKillIntegral);
					PrintToChat(i,"\x03你给予了\x04Tank\x03致命一击,额外收获\x04%d\x03积分,余额\x04%d\x03积分",GetConVarInt(TankKillIntegral),Integral[i]);				//坦克
					if(Integral[i] > GetConVarInt(MaxIntegral))
					{
						PrintToChat(i,"\x05你的\x04积分已满\x05,请注意!");
					}
					else if(Integral[i]/GetConVarFloat(MaxIntegral)>GetConVarFloat(WarningIntegral))
					{
						PrintToChat(i,"\x03你的积分已上限\x04 %0.0f%% \x03请尽快使用!",GetConVarFloat(WarningIntegral)*100);
					}
				}
			}
			if(Integral[i] > GetConVarInt(MaxIntegral))
			{	
				Integral[i] = GetConVarInt(MaxIntegral);
			}
		}
	}
}

//救援来了的方法
public int evtFinaleVehicleLeaving(Event event, const char[] name, bool dontBroadcast)
{
	Rescueflag=false;
	
	for(int i=1; i <= MAXPLAYERS; i++)
	{
		Integral[i] = 0;
		KillZombies[i] = 0;
	}
	
	return;
}

public int GiveMenu(Menu menu, MenuAction action, int param1, int param2) 
{
	switch (action) 
	{
		case MenuAction_Select: 
		{
			char item[8];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			Integral[StringToInt(item)] += GiveNumber;
			PrintToChatAll("\x03管理员给予了\x04你\x03共\x04%i\x03积分!",GiveNumber);
			
			GiveNumber = 0;
			
		}
		case MenuAction_End:
			delete menu;
	}
}

public Action GiveAllIntegral(int client, int args)
{	
	char Num[20];
	GetCmdArg(1, Num, sizeof(Num));
	
	if(StringToInt(Num) > GetConVarInt(MaxIntegral))
	{
		PrintToChat(client,"\x03你输入的积分\x04大于\x03最大值积分,当前默认\x04修改\x03为最大积分值!");
		for(int i=1; i <= MaxClients; i++)
		{
			if(IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == 2 && !IsFakeClient(i))
			{
				Integral[i] += GetConVarInt(MaxIntegral);
				if(Integral[i] > GetConVarInt(MaxIntegral))
				{	
					Integral[i] = GetConVarInt(MaxIntegral);
				}
			}
		}
		
		PrintToChatAll("\x04管理员\x03给予\x04全部\x03玩家\x04%d\x03积分!",GetConVarInt(MaxIntegral));
	}
	else if(StringToInt(Num) < 0)
	{
		PrintToChat(client,"\x03你输入的积分\x04小于\x03最小值积分\x04 0,\x03请\x04重新\x03输入!");
	}
	else
	{
		for(int i=1; i <= MaxClients; i++)
		{
			if(IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == 2 && !IsFakeClient(i))
			{
				Integral[i] += StringToInt(Num);
				if(Integral[i] > StringToInt(Num))
				{	
					Integral[i] = StringToInt(Num);
				}
			}
		}
		
		PrintToChatAll("\x04管理员\x03给予\x04全部\x03玩家\x04%d\x03积分!",StringToInt(Num));
	}
}

//这是主界面

public int CharMenu(Menu menu, MenuAction action, int param1, int param2) 
{
	switch (action) 
	{
		case MenuAction_Select: 
		{
			char item[8];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			switch(StringToInt(item)) 
			{
				case ARMS:
				{
					ShowTypeMenu(param1,ARMS);
				}
				case MELEE:
				{
					ShowTypeMenu(param1,MELEE);
				}
				case MELEE2:
				{
					ShowTypeMenu(param1,MELEE2);
				}
				case PROPS:
				{
					ShowTypeMenu(param1,PROPS);
				}
				case VARIA:
				{
					ShowTypeMenu(param1,VARIA);
				}
				case SKINMENU:
				{
					ShowTypeMenu(param1,SKINMENU);
				}
				case KILLMENU:
				{
					ShowTypeMenu(param1,KILLMENU);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				ShowMenu(param1, false);
		}
		case MenuAction_End:
			delete menu;
	}
}

public Action ShowMenu(int client, int args)
{	
	if(Rescueflag)
	{
		char sMenuEntry[8];
		
		Menu menu = new Menu(CharMenu);
		menu.SetTitle("积分商城\n你的积分为 %i 分.",Integral[client]);
		if(!GetEntProp(client, Prop_Send, "m_lifeState"))
		{
			IntToString(ARMS, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, "购买枪械武器");
			
			IntToString(MELEE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, "购买近战武器");
			
			IntToString(MELEE2, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, "购买三方图近战武器");

			IntToString(PROPS, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, "购买药物弹药");
			
			IntToString(VARIA, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, "杂物购买");

			IntToString(SKINMENU, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, "人物皮肤颜色购买");

			IntToString(KILLMENU, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, "特殊项目购买");
		}
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

//这是购买武器

public int CharArmsMenu(Menu menu, MenuAction action, int param1, int param2) 
{
	switch (action) 
	{
		case MenuAction_Select: 
		{
			char item[8];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			switch(StringToInt(item)) 
			{
				case PISTOL:
				{
					int money = GetConVarInt(pistolmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");}
					else{CheatCommand(param1, "give pistol");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04普通手枪\x03.",money);}
				}
				case MAGNUM:	
				{	
					int money = GetConVarInt(magnummoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give pistol_magnum");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04马格南手枪\x03.",money);}
				}
				case SMG:	
				{	
					int money = GetConVarInt(smgmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give smg");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04UZI冲锋枪\x03.",money);}
				}
				case SMGSILENCED:	
				{	
					int money = GetConVarInt(smgsilencedmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give smg_silenced");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04消声冲锋枪\x03.",money);}
				}
				case MP5:	
				{	
					int money = GetConVarInt(mp5money);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give smg_mp5 ");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04MP5冲锋枪\x03.",money);}
				}
				case PUMPSHOTGUN1:
				{
					int money = GetConVarInt(pumpshotgun1money);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give pumpshotgun");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04老式单发霰弹枪\x03.",money);}
				}
				case PUMPSHOTGUN2:
				{
					int money = GetConVarInt(pumpshotgun2money);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give shotgun_chrome");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04新式单发霰弹枪\x03.",money);}
				}
				case AUTOSHOTGUN1:
				{
					int money = GetConVarInt(autoshotgun1money);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give autoshotgun");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04老式连发霰弹枪\x03.",money);}
				}
				case AUTOSHOTGUN2:
				{
					int money = GetConVarInt(autoshotgun2money);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give shotgun_spas");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04新式连发霰弹枪\x03.",money);}
				}
				case HUNTING1:
				{
					int money = GetConVarInt(hunting1money);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give hunting_rifle");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04猎枪\x03.",money);}
				}
				case HUNTING2:
				{
					int money = GetConVarInt(hunting2money);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give sniper_military");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04G3SG1狙击枪\x03.",money);}
				}
				case SNIPERSCOUT:
				{
					int money = GetConVarInt(sniperscoutmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give sniper_scout");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04斯太尔小型狙击枪\x03.",money);}
				}
				case AWP:
				{
					int money = GetConVarInt(awpmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give sniper_awp");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04麦格农大型狙击枪\x03.",money);}
				}
				case M16:
				{
					int money = GetConVarInt(m16money);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give rifle");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04M16步枪\x03.",money);}
				}
				case AK47:
				{
					int money = GetConVarInt(ak47money);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give rifle_ak47");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04AK47步枪\x03.",money);}
				}
				case SCAR:
				{
					int money = GetConVarInt(scarmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give rifle_desert");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04SCAR步枪\x03.",money);}
				}
				case SG552:
				{
					int money = GetConVarInt(sg552money);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give rifle_sg552");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04SG552步枪\x03.",money);}
				}
				case M60:
				{
					int money = GetConVarInt(m60money);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give rifle_m60");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04m60机枪\x03.",money);}
				}
				case GRENADELAUNCHER:
				{
					int money = GetConVarInt(grenadelaunchermoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give grenade_launcher");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04榴弹发射器\x03.",money);}
				}
				case CROWBAR:
				{
					int money = GetConVarInt(crowbarmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give crowbar");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04撬棍\x03.",money);}
				}
				case FIREAXE:
				{
					int money = GetConVarInt(fireaxemoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give fireaxe");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04斧头\x03.",money);}
				}
				case KNIFE:
				{
					int money = GetConVarInt(knifemoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give knife");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04小刀\x03.",money);}
				}
				case KATANA:
				{
					int money = GetConVarInt(katanamoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give katana");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04武士刀\x03.",money);}
				}
				case SHOVEL:
				{
					int money = GetConVarInt(shovelmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give shovel");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04铁铲\x03.",money);}
				}
				case PITCHFORK:
				{
					int money = GetConVarInt(pitchforkmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give pitchfork");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04干草叉\x03.",money);}
				}
				case CRICKETBAT:
				{
					int money = GetConVarInt(cricketbatmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give cricket_bat");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04板球拍\x03.",money);}
				}
				case BASEBALLBAT:
				{
					int money = GetConVarInt(baseballbatmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give baseball_bat");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04棒球棒\x03.",money);}
				}
				case FRYINGPAN:
				{
					int money = GetConVarInt(fryingpanmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give frying_pan");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04平底锅\x03.",money);}
				}
				case GUITAR:
				{
					int money = GetConVarInt(guitarmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give electric_guitar");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04电吉他\x03.",money);}
				}
				case TONFA:
				{
					int money = GetConVarInt(tonfamoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give tonfa");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04警棍\x03.",money);}
				}
				case MACHETE:
				{
					int money = GetConVarInt(machetemoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give machete");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04砍刀\x03.",money);}
				}
				case CHAINSAW:
				{
					int money = GetConVarInt(chainsawmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give chainsaw");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04电锯\x03.",money);}
				}
				case ADRENALINE:
				{
					int money = GetConVarInt(adrenalinemoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give adrenaline");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04肾上腺素\x03.",money);}
				}
				case PAINPILLS:
				{
					int money = GetConVarInt(painpillsmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give pain_pills");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04止痛药\x03.",money);}
				}
				case FIRSTAIDKIT:
				{
					int money = GetConVarInt(firstaidkitmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give first_aid_kit");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04急救包\x03.",money);}
				}
				case DEFIBRILLATOR:
				{
					int money = GetConVarInt(defibrillatormoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give defibrillator");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04电击器\x03.",money);}
				}
				case PIPEBOMB:
				{
					int money = GetConVarInt(pipebombmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give pipe_bomb");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04土制炸药\x03.",money);}
				}
				case VOMITJAR:
				{
					int money = GetConVarInt(vomitjarmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give vomitjar");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04胆汁\x03.",money);}
				}
				case MOLOTOV:
				{
					int money = GetConVarInt(molotovmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give molotov");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04燃烧瓶\x03.",money);}
				}
				case EXPLOSIVEPACK:
				{
					int money = GetConVarInt(explosivepackmoney);
					float location[3];
					if (!Misc_TraceClientViewToLocation(param1, location)) 
					{
						GetClientAbsOrigin(param1, location);
					}
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{ 
						Do_CreateEntity(param1, "upgrade_ammo_explosive", "PROVIDED", location, false); 
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04部署好的\x03高爆弹药盒子.",money);
					}
				}
				case INCENDIARYPACK:
				{
					int money = GetConVarInt(incendiarypackmoney);
					float location[3];
					if (!Misc_TraceClientViewToLocation(param1, location)) 
					{
						GetClientAbsOrigin(param1, location);
					}
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{ 
						Do_CreateEntity(param1, "upgrade_ammo_incendiary", "PROVIDED", location, false);
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04部署好的\x03燃烧弹药盒子.",money);
					}
					
				}
				case LASERPACK:
				{
					int money = GetConVarInt(laserpackmoney);
					float location[3];
					if (!Misc_TraceClientViewToLocation(param1, location)) 
					{
						GetClientAbsOrigin(param1, location);
					}
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{ 
						Do_CreateEntity(param1, "upgrade_laser_sight", "PROVIDED", location, false);
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x03红外线盒子.",money);
					}
					
				}
				case EXPLOSIVE:
				{
					int money = GetConVarInt(explosivemoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "upgrade_add explosive_ammo");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04装载了\x03高爆子弹.",money);}
				}
				case INCENDIARY:
				{
					int money = GetConVarInt(incendiarymoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "upgrade_add Incendiary_ammo");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04装载了\x03燃烧子弹.",money);}
				}
				case UPGRADELASER:
				{
					int money = GetConVarInt(upgradelasermoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "upgrade_add laser_sight");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04升级\x03了自己的武器.",money);}
				}
				case HEALTH:
				{
					int money = GetConVarInt(healthmoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足\x03以购买!");
					} 
					else
					{
						CheatCommand(param1, "give health");
						SetEntPropFloat(param1, Prop_Send, "m_healthBuffer", 0.0);
						Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04恢复了\x03自己的生命值.",money);
					}
				}
				case AMMO:
				{
					int money = GetConVarInt(ammomoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give ammo");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04补满\x03自己的主武器子弹.",money);}
				}
				case GASCAN:
				{
					int money = GetConVarInt(gascanmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give gascan");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04汽油桶\x03.",money);}
				}
				case PROPANETANK:
				{
					int money = GetConVarInt(propanetankmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give propanetank");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04煤气瓶\x03.",money);}
				}
				case OXYGENTANK:
				{
					int money = GetConVarInt(oxygentankmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give oxygentank");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04氧气瓶\x03.",money);}
				}
				case FIREWORKCRATE:
				{
					int money = GetConVarInt(fireworkcratemoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give weapon_fireworkcrate");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04烟花盒子\x03.",money);}
				}
				case GNOME:
				{
					int money = GetConVarInt(gnomemoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give weapon_gnome");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04小矮人\x03.",money);}
				}
				case LEONKNIFE:
				{
					int money = GetConVarInt(leonknifemoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give leon_knife");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04里昂匕首\x03.",money);}
				}
				case BAJOROKU:
				{
					int money = GetConVarInt(bajorokumoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give bajo_roku");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04黑色吉他\x03.",money);}
				}
				case HAMMERROKU:
				{
					int money = GetConVarInt(hammerrokumoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give hammer_roku");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04生化铁锤\x03.",money);}
				}
				case ZUKO:
				{
					int money = GetConVarInt(zukomoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give zuko");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04火焰镰刀\x03.",money);}
				}
				case GUANDAO:
				{
					int money = GetConVarInt(guandaomoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give guandao");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04青龙偃月刀\x03.",money);}
				}
				case WULINMIJI:
				{
					int money = GetConVarInt(wulinmijimoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give wulinmiji");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04武林秘笈\x03.",money);}
				}
				case DAGGERWATER:
				{
					int money = GetConVarInt(daggerwatermoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give dagger_water");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04水蓝短剑\x03.",money);}
				}
				case SCYTHEROKU:
				{
					int money = GetConVarInt(scytherokumoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give scythe_roku");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04死神镰刀\x03.",money);}
				}
				case BIGORONSWORD:
				{
					int money = GetConVarInt(bigoronswordmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give bigoronsword");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04比戈龙剑\x03.",money);}
				}
				case DEKUSTICK:
				{
					int money = GetConVarInt(dekustickmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give dekustick");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04树枝\x03.",money);}
				}
				case HAMMER:
				{
					int money = GetConVarInt(hammermoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give hammer");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04大铁锤\x03.",money);}
				}
				case HYLIANSHIELD:
				{
					int money = GetConVarInt(hylianshieldmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give hylianshield");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04海莲盾\x03.",money);}
				}
				case KICTHENKNIFE:
				{
					int money = GetConVarInt(kicthenknifemoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give kicthenknife");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04克钦小刀\x03.",money);}
				}
				case MASTERSWORD:
				{
					int money = GetConVarInt(masterswordmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give mastersword");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04王者之剑\x03.",money);}
				}
				case MIRRORSHIELD:
				{
					int money = GetConVarInt(mirrorshieldmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give mirrorshield");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04镜之盾\x03.",money);}
				}
				case ROCKAXE:
				{
					int money = GetConVarInt(rockaxemoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give rockaxe");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04登山斧\x03.",money);}
				}

				case SCUP:
				{
					int money = GetConVarInt(scupmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give scup");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04杯子\x03.",money);}
				}
				case CAIDAO:
				{
					int money = GetConVarInt(caidaomoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give caidao");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04菜刀\x03.",money);}
				}
				case CHAIR:
				{
					int money = GetConVarInt(chairmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give chair");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04椅子\x03.",money);}
				}
				case FINGER:
				{
					int money = GetConVarInt(fingermoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give finger");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04红手指\x03.",money);}
				}
				case MELEEJB:
				{
					int money = GetConVarInt(meleejbmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give meleejb");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04JB近战\x03.",money);}
				}
				case ONION:
				{
					int money = GetConVarInt(onionmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give onion");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04洋葱\x03.",money);}
				}
				case PINGPANG:
				{
					int money = GetConVarInt(pingpangmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give pingpang");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04乒乓球拍\x03.",money);}
				}
				case WRENCH:
				{
					int money = GetConVarInt(wrenchmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give wrench");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04扳手\x03.",money);}
				}
				case FLAMETHROWER:
				{
					int money = GetConVarInt(flamethrowermoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CheatCommand(param1, "give flamethrower");Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分购买了\x04喷火枪\x03.",money);}
				}
				case KILLCOMMON:
				{
					int money = GetConVarInt(killcommonmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{KillAllCommonInfected(param1);Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分清理掉\x04全部\x03小僵尸.",money);}
				}
				case KILLWITCH:
				{
					int money = GetConVarInt(killwitchmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{ KillAllWitches();Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分清理掉地图\x04全部\x03女巫.",money);}
				}
				case KILLWITCHS:
				{
					int money = GetConVarInt(killwitchesmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{ KillWitches(param1);Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分杀死了\x04全部\x03女巫.",money);}
				}

				case KILLINFECTED:
				{
					int money = GetConVarInt(killinfectedmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{ KillAllInfected();Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分杀死了\x04全部\x03特感.",money);}
				}

				case CREATEFIRE:
				{
					int money = GetConVarInt(createfiremoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CreateFires(param1);Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分在\x04自己脚下\x03点了把火.",money);}
				}
				case CREATEBOMB:
				{
					int money = GetConVarInt(createbombmoney);
					if(Integral[param1] < money){ PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");} 
					else{CreateBomb(param1);Integral[param1] -= money;PrintToChat(param1,"\x03你花了\x04%i\x03积分在\x04自己脚下\x03放了个炸弹.",money);}
				}
				case INFINITEAMMO:
				{
					int money = GetConVarInt(infiniteammomoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{
						InfiniteAmmo[param1] = true;
						Throwing[param1] = 1;
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04购买了\x03无限补给.",money);
					}
				}
				case GODMODE:
				{
					int money = GetConVarInt(godmodemoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{
						GodMode[param1] = true;
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04购买了\x03无敌模式.",money);
					}
				}
				case SWARMMODE:
				{
					int money = GetConVarInt(swarmmodemoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{
						SwarmMode[param1] = true;
						WitchDamage[param1] = true;
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04购买了\x03抵抗力,\x05一段时间内抵抗酸液伤害和女巫攻击.",money);
					}
				}
				
				case IMMUNEDAMAGE:
				{
					int money = GetConVarInt(immunedamagemoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{
						ImmuneMode[param1] = true;
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04购买了\x03友伤免疫,\x05暂时不会受到友军伤害.",money);
					}
				}

				case AMMOSTACK:
				{
					int money = GetConVarInt(ammostackmoney);
					float location[3];
					if (!Misc_TraceClientViewToLocation(param1, location)) 
					{
						GetClientAbsOrigin(param1, location);
					}
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{ 
						Do_CreateEntity(param1, "weapon_ammo_spawn", "models/props/terror/ammo_stack.mdl", location, false); 
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分创建了\x04弹药堆\x03.",money);
					}
				}
				case WHITE:
				{
					SetEntityRenderColor(param1, 255, 255, 255, 255);
					PrintToChat(param1,"\x03皮肤颜色 \x05恢复默认.");
				}
				case BLACK:
				{
					int money = GetConVarInt(skinblackmoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{
						SetEntityRenderColor(param1, 0, 0, 0, 255);
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04购买了\x03黑色皮肤.",money);
					}
				}
				case INVISIBLE:
				{
					int money = GetConVarInt(skininvisiblemoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{
						SetEntityRenderColor(param1, 100, 100, 100, 100);
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04购买了\x03透明皮肤.",money);
					}
				}				
				case RED:
				{
					int money = GetConVarInt(skinredmoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{
						SetEntityRenderColor(param1, 255, 0, 0, 255);
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04购买了\x03红色皮肤.",money);
					}
				}
				case GREEN:
				{
					int money = GetConVarInt(skingreenmoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{
						SetEntityRenderColor(param1, 0, 255, 0, 255);
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04购买了\x03绿色皮肤.",money);
					}
				}
				case BLUE:
				{
					int money = GetConVarInt(skinbluemoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{
						SetEntityRenderColor(param1, 0, 0, 255, 255);
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04购买了\x03蓝色皮肤.",money);
					}
				}
				case YELLOW:
				{
					int money = GetConVarInt(skinyellowmoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{
						SetEntityRenderColor(param1, 255, 255, 0, 255);
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04购买了\x03黄色皮肤.",money);
					}
				}
				case PURPLE:
				{
					int money = GetConVarInt(skinpurplemoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{
						SetEntityRenderColor(param1, 160, 32, 240, 255);
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04购买了\x03紫色皮肤.",money);
					}
				}
				case PINK:
				{
					int money = GetConVarInt(skinpinkmoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{
						SetEntityRenderColor(param1, 255, 0, 255, 255);
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04购买了\x03粉红色皮肤.",money);
					}
				}
				case CYAN:
				{
					int money = GetConVarInt(skincyanmoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{
						SetEntityRenderColor(param1, 0, 255, 255, 255);
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04购买了\x03青色皮肤.",money);
					}
				}
				case GOLD:
				{
					int money = GetConVarInt(skingoldmoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{
						SetEntityRenderColor(param1, 255, 215, 0, 255);
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04购买了\x03金色皮肤.",money);
					}
				}
				case ICEBLUE:
				{
					int money = GetConVarInt(skinicebluemoney);
					if(Integral[param1] < money)
					{ 
						PrintToChat(param1,"\x03积分\x04不足,\x03无法购买!");
					} 
					else
					{
						SetEntityRenderColor(param1, 0, 128, 255, 255);
						Integral[param1] -= money;
						PrintToChat(param1,"\x03你花了\x04%i\x03积分\x04购买了\x03冰蓝色皮肤.",money);
					}
				}
			}
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
				ShowMenu(param1, false);
		}
		case MenuAction_End:
			delete menu;
	}
}

public void ShowTypeMenu(int client, int type)
{	
	char sMenuEntry[8];
	char money[64];
	Menu menu = new Menu(CharArmsMenu);
	switch(type)
	{
		case ARMS:
		{
			menu.SetTitle("积分商城\n你的积分为 %i 分",Integral[client]);
			
			FormatEx(money,sizeof(money),"普通手枪(%d积分)",GetConVarInt(pistolmoney));
			IntToString(PISTOL, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"马格南手枪(%d积分)",GetConVarInt(magnummoney));
			IntToString(MAGNUM, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"UZI冲锋枪(%d积分)",GetConVarInt(smgmoney));
			IntToString(SMG, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"消声冲锋枪(%d积分)",GetConVarInt(smgsilencedmoney));
			IntToString(SMGSILENCED, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"MP5冲锋枪(%d积分)",GetConVarInt(mp5money));
			IntToString(MP5, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"1代单发霰弹枪(%d积分)",GetConVarInt(pumpshotgun1money));
			IntToString(PUMPSHOTGUN1, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"2代单发霰弹枪(%d积分)",GetConVarInt(pumpshotgun2money));
			IntToString(PUMPSHOTGUN2, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"1代连发霰弹枪(%d积分)",GetConVarInt(autoshotgun1money));
			IntToString(AUTOSHOTGUN1, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"2代连发霰弹枪(%d积分)",GetConVarInt(autoshotgun2money));
			IntToString(AUTOSHOTGUN2, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"猎枪(%d积分)",GetConVarInt(hunting1money));
			IntToString(HUNTING1, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"军用狙击枪(%d积分)",GetConVarInt(hunting2money));
			IntToString(HUNTING2, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"scout轻型狙击枪(%d积分)",GetConVarInt(sniperscoutmoney));
			IntToString(SNIPERSCOUT, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"awp重型狙击枪(%d积分)",GetConVarInt(awpmoney));
			IntToString(AWP, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"M16步枪(%d积分)",GetConVarInt(m16money));
			IntToString(M16, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"AK47步枪(%d积分)",GetConVarInt(ak47money));
			IntToString(AK47, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"SCAR步枪(%d积分)",GetConVarInt(scarmoney));
			IntToString(SCAR, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"SG552步枪(%d积分)",GetConVarInt(sg552money));
			IntToString(SG552, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"m60机枪(%d积分)",GetConVarInt(m60money));
			IntToString(M60, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"榴弹发射器(%d积分)",GetConVarInt(grenadelaunchermoney));
			IntToString(GRENADELAUNCHER, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
		}
		case MELEE:
		{
			menu.SetTitle("积分商城\n你的积分为 %i 分",Integral[client]);
			FormatEx(money,sizeof(money),"武士刀(%d积分)",GetConVarInt(katanamoney));
			IntToString(KATANA, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"砍刀(%d积分)",GetConVarInt(machetemoney));
			IntToString(MACHETE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"小刀(%d积分)",GetConVarInt(knifemoney));
			IntToString(KNIFE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"斧头(%d积分)",GetConVarInt(fireaxemoney));
			IntToString(FIREAXE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"铁铲(%d积分)",GetConVarInt(shovelmoney));
			IntToString(SHOVEL, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"干草叉(%d积分)",GetConVarInt(pitchforkmoney));
			IntToString(PITCHFORK, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"板球拍(%d积分)",GetConVarInt(cricketbatmoney));
			IntToString(CRICKETBAT, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"棒球棍(%d积分)",GetConVarInt(baseballbatmoney));
			IntToString(BASEBALLBAT, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"平底锅(%d积分)",GetConVarInt(fryingpanmoney));
			IntToString(FRYINGPAN, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"电吉他(%d积分)",GetConVarInt(guitarmoney));
			IntToString(GUITAR, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"警棍(%d积分)",GetConVarInt(tonfamoney));
			IntToString(TONFA, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"电锯(%d积分)",GetConVarInt(chainsawmoney));
			IntToString(CHAINSAW, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
		}
		case MELEE2:
		{
			menu.SetTitle("积分商城\n你的积分为 %i 分",Integral[client]);
			FormatEx(money,sizeof(money),"里昂匕首（生化危机专用）(%d积分)",GetConVarInt(leonknifemoney));
			IntToString(LEONKNIFE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"黑色吉他（生化危机专用）(%d积分)",GetConVarInt(bajorokumoney));
			IntToString(BAJOROKU, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"生化铁锤（生化危机专用）(%d积分)",GetConVarInt(hammerrokumoney));
			IntToString(HAMMERROKU, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"火焰镰刀（生化危机专用）(%d积分)",GetConVarInt(zukomoney));
			IntToString(ZUKO, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"青龙偃月刀（晨茗专用）(%d积分)",GetConVarInt(guandaomoney));
			IntToString(GUANDAO, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"武林秘笈（晨茗专用）(%d积分)",GetConVarInt(wulinmijimoney));
			IntToString(WULINMIJI, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"水蓝短剑（生化1专用）(%d积分)",GetConVarInt(daggerwatermoney));
			IntToString(DAGGERWATER, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"死神镰刀（生化3专用）(%d积分)",GetConVarInt(scytherokumoney));
			IntToString(SCYTHEROKU, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"比戈龙剑（死亡山谷专用）(%d积分)",GetConVarInt(bigoronswordmoney));
			IntToString(BIGORONSWORD, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"树枝（死亡山谷专用）(%d积分)",GetConVarInt(dekustickmoney));
			IntToString(DEKUSTICK, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"大铁锤（增城与死亡山谷专用）(%d积分)",GetConVarInt(hammermoney));
			IntToString(HAMMER, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"海莲盾（死亡山谷专用）(%d积分)",GetConVarInt(hylianshieldmoney));
			IntToString(HYLIANSHIELD, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"克钦小刀（死亡山谷专用）(%d积分)",GetConVarInt(kicthenknifemoney));
			IntToString(KICTHENKNIFE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"王者之剑（死亡山谷专用）(%d积分)",GetConVarInt(masterswordmoney));
			IntToString(MASTERSWORD, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"镜之盾（死亡山谷专用）(%d积分)",GetConVarInt(mirrorshieldmoney));
			IntToString(MIRRORSHIELD, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"登山斧（死亡山谷专用）(%d积分)",GetConVarInt(rockaxemoney));
			IntToString(ROCKAXE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"杯子（死亡山谷专用）(%d积分)",GetConVarInt(scupmoney));
			IntToString(SCUP, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"菜刀（增城专用）(%d积分)",GetConVarInt(caidaomoney));
			IntToString(CAIDAO, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"椅子（增城专用）(%d积分)",GetConVarInt(chairmoney));
			IntToString(CHAIR, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"红手指（增城专用）(%d积分)",GetConVarInt(fingermoney));
			IntToString(FINGER, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"JB近战（增城专用）(%d积分)",GetConVarInt(meleejbmoney));
			IntToString(MELEEJB, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"洋葱（增城专用）(%d积分)",GetConVarInt(onionmoney));
			IntToString(ONION, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"乒乓球拍（增城专用）(%d积分)",GetConVarInt(pingpangmoney));
			IntToString(PINGPANG, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"扳手（增城专用）(%d积分)",GetConVarInt(wrenchmoney));
			IntToString(WRENCH, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"喷火枪（黎明专用）(%d积分)",GetConVarInt(wrenchmoney));
			IntToString(FLAMETHROWER, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
		}
		case PROPS:
		{
			menu.SetTitle("积分商城\n你的积分为 %i 分",Integral[client]);
			
			FormatEx(money,sizeof(money),"恢复生命(%d积分)",GetConVarInt(healthmoney));
			IntToString(HEALTH, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"弹药(%d积分)",GetConVarInt(ammomoney));
			IntToString(AMMO, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"肾上腺素(%d积分)",GetConVarInt(adrenalinemoney));
			IntToString(ADRENALINE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"止痛药(%d积分)",GetConVarInt(painpillsmoney));
			IntToString(PAINPILLS, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"医疗包(%d积分)",GetConVarInt(firstaidkitmoney));
			IntToString(FIRSTAIDKIT, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"电击器(%d积分)",GetConVarInt(defibrillatormoney));
			IntToString(DEFIBRILLATOR, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"土制炸药(%d积分)",GetConVarInt(pipebombmoney));
			IntToString(PIPEBOMB, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"胆汁(%d积分)",GetConVarInt(vomitjarmoney));
			IntToString(VOMITJAR, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"燃烧瓶(%d积分)",GetConVarInt(molotovmoney));
			IntToString(MOLOTOV, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"红外线(%d积分)",GetConVarInt(upgradelasermoney));
			IntToString(UPGRADELASER, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"高爆子弹(%d积分)",GetConVarInt(explosivemoney));
			IntToString(EXPLOSIVE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"燃烧子弹(%d积分)",GetConVarInt(incendiarymoney));
			IntToString(INCENDIARY, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"部署高爆弹药铁箱(%d积分)",GetConVarInt(explosivepackmoney));
			IntToString(EXPLOSIVEPACK, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"部署燃烧弹药铁箱(%d积分)",GetConVarInt(incendiarypackmoney));
			IntToString(INCENDIARYPACK, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"部署红外线铁箱(%d积分)",GetConVarInt(laserpackmoney));
			IntToString(LASERPACK, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
		}		
		case VARIA:
		{
			menu.SetTitle("积分商城\n你的积分为 %i 分",Integral[client]);
			FormatEx(money,sizeof(money),"汽油桶(%d积分)",GetConVarInt(gascanmoney));
			IntToString(GASCAN, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"煤气瓶(%d积分)",GetConVarInt(propanetankmoney));
			IntToString(PROPANETANK, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"氧气瓶(%d积分)",GetConVarInt(oxygentankmoney));
			IntToString(OXYGENTANK, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"烟花盒子(%d积分)",GetConVarInt(fireworkcratemoney));
			IntToString(FIREWORKCRATE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"小矮人(%d积分)",GetConVarInt(gnomemoney));
			IntToString(GNOME, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"弹药堆(%d积分)",GetConVarInt(ammostackmoney));
			IntToString(AMMOSTACK, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
		}
		case SKINMENU:
		{
			menu.SetTitle("积分商城\n你的积分为 %i 分",Integral[client]);
			FormatEx(money,sizeof(money),"恢复默认皮肤");
			IntToString(WHITE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"黑色皮肤(%d积分)",GetConVarInt(skinblackmoney));
			IntToString(BLACK, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"透明皮肤(%d积分)",GetConVarInt(skininvisiblemoney));
			IntToString(INVISIBLE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"红色皮肤(%d积分)",GetConVarInt(skinredmoney));
			IntToString(RED, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"绿色皮肤(%d积分)",GetConVarInt(skingreenmoney));
			IntToString(GREEN, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"蓝色皮肤(%d积分)",GetConVarInt(skinbluemoney));
			IntToString(BLUE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"黄色皮肤(%d积分)",GetConVarInt(skinyellowmoney));
			IntToString(YELLOW, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"紫色皮肤(%d积分)",GetConVarInt(skinpurplemoney));
			IntToString(PURPLE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"粉红色皮肤(%d积分)",GetConVarInt(skinpinkmoney));
			IntToString(PINK, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"青色皮肤(%d积分)",GetConVarInt(skincyanmoney));
			IntToString(CYAN, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"金色皮肤(%d积分)",GetConVarInt(skingoldmoney));
			IntToString(GOLD, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"冰蓝色皮肤(%d积分)",GetConVarInt(skinicebluemoney));
			IntToString(ICEBLUE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
		}
		case KILLMENU:
		{
			menu.SetTitle("积分商城\n你的积分为 %i 分",Integral[client]);
			FormatEx(money,sizeof(money),"杀死全部小僵尸(%d积分)",GetConVarInt(killcommonmoney));
			IntToString(KILLCOMMON, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"杀死全部特感(%d积分)",GetConVarInt(killinfectedmoney));
			IntToString(KILLINFECTED, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"杀死全部女巫(%d积分)",GetConVarInt(killwitchesmoney));
			IntToString(KILLWITCHS, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"清除地图上的女巫(%d积分)",GetConVarInt(killwitchmoney));
			IntToString(KILLWITCH, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
			
			FormatEx(money,sizeof(money),"在自己脚下放火(%d积分)",GetConVarInt(createfiremoney));
			IntToString(CREATEFIRE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"在自己脚下放炸弹(%d积分)",GetConVarInt(createbombmoney));
			IntToString(CREATEBOMB, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"无敌模式(%d积分)",GetConVarInt(godmodemoney));
			IntToString(GODMODE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"无限补给(%d积分)",GetConVarInt(infiniteammomoney));
			IntToString(INFINITEAMMO, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"抵抗力(%d积分)",GetConVarInt(swarmmodemoney));
			IntToString(SWARMMODE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);

			FormatEx(money,sizeof(money),"友伤免疫(%d积分)",GetConVarInt(immunedamagemoney));
			IntToString(IMMUNEDAMAGE, sMenuEntry, sizeof(sMenuEntry));
			menu.AddItem(sMenuEntry, money);
		}
	}
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

void Do_CreateEntity(int client, const char[] name, const char[] model, float location[3], const bool zombie) 
{
	int entity = CreateEntityByName(name);
	if (StrEqual(model, "PROVIDED") == false)
		SetEntityModel(entity, model);
	DispatchSpawn(entity);
	if (zombie) 
	{
		int ticktime = RoundToNearest(GetGameTime() / GetTickInterval()) + 5;
		SetEntProp(zombie, Prop_Data, "m_nNextThinkTick", ticktime);
		location[2] -= 25.0; // reduce the 'drop' effect
	}
	// Starts animation on whatever we spawned - necessary for mobs
	ActivateEntity(entity);
	// Teleport the entity to the client's crosshair
	TeleportEntity(entity, location, NULL_VECTOR, NULL_VECTOR);
	LogAction(client, -1, "", client, name, model);
}

bool Misc_TraceClientViewToLocation(int client, float location[3]) 
{
	float vAngles[3], vOrigin[3];
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	// PrintToChatAll("Running Code %f %f %f | %f %f %f", vOrigin[0], vOrigin[1], vOrigin[2], vAngles[0], vAngles[1], vAngles[2]);
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);
	if(TR_DidHit(trace)) 
	{
		TR_GetEndPosition(location, trace);
		CloseHandle(trace);
		// PrintToChatAll("Collision at %f %f %f", location[0], location[1], location[2]);
		return true;
	}
	CloseHandle(trace);
	return false;
}

public bool TraceRayDontHitSelf(int entity, int mask, any data) 
{
	if(entity == data) 
	{ // Check if the TraceRay hit the itself.
		return false; // Don't let the entity be hit
	}
	return true; // It didn't hit itself
}

void CheatCommand(int client, const char[] sCommand)
{
	if(client == 0 || !IsClientInGame(client))
		return;

	char sCmd[32];
	if(SplitString(sCommand, " ", sCmd, sizeof(sCmd)) == -1)
		strcopy(sCmd, sizeof(sCmd), sCommand);

	if(strcmp(sCmd, "give") == 0)
	{
		if(strcmp(sCommand[5], "health") == 0)
			SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0); //防止有虚血时give health会超过100血
		else if(strcmp(sCommand[5], "ammo") == 0)
			ReloadAmmo(client); //M60和榴弹发射器加子弹
	}

	int bits = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	int flags = GetCommandFlags(sCmd);
	SetCommandFlags(sCmd, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, sCommand);
	SetCommandFlags(sCmd, flags);
	SetUserFlagBits(client, bits);
}

void ReloadAmmo(int client)
{
	int iWeapon = GetPlayerWeaponSlot(client, 0);
	if(iWeapon > MaxClients && IsValidEntity(iWeapon))
	{

		char sWeapon[64];
		GetEdictClassname(iWeapon, sWeapon, sizeof(sWeapon));
		if(strcmp(sWeapon, "weapon_rifle_m60") == 0)
		{
			if(g_iClipSize_RifleM60 <= 0)
				g_iClipSize_RifleM60 = 150;

			SetEntProp(iWeapon, Prop_Send, "m_iClip1", g_iClipSize_RifleM60);
		}	
		else if(strcmp(sWeapon, "weapon_grenade_launcher") == 0)
		{
			if(g_iClipSize_GrenadeLauncher <= 0)
				g_iClipSize_GrenadeLauncher = 1;
			
			SetEntProp(iWeapon, Prop_Send, "m_iClip1", g_iClipSize_GrenadeLauncher);

			int iAmmo_Max = FindConVar("ammo_grenadelauncher_max").IntValue;
			if(iAmmo_Max <= 0)
				iAmmo_Max = 60;

			SetEntData(client, FindSendPropInfo("CTerrorPlayer", "m_iAmmo") + 68, iAmmo_Max);
		}
	}
}

void KillAllCommonInfected(int client)
{
	for (int i = MaxClients; i <= 2048; i++)
	{
		if (!IsValidEntity(i))
			continue;
		
		static char szClass[36];
		GetEntityClassname(i, szClass, sizeof szClass);
		
		if (strcmp(szClass, "infected") == 0)
			ForceDamageEntity(client, 1000, i);
	}
}

void KillWitches(int client)
{
	for (int i = MaxClients; i <= 2048; i++)
	{
		if (!IsValidEntity(i))
			continue;
		
		static char szClass[64];
		GetEntityClassname(i, szClass, sizeof szClass);
		
		if (strcmp(szClass, "witch") == 0)
			ForceDamageEntity(client, 1000, i);
	}
}

void ForceDamageEntity(int causer, int damage, int victim)
{
	float victim_origin[3];
	char rupture[32];
	char damage_victim[32];
	IntToString(damage, rupture, sizeof(rupture));
	Format(damage_victim, sizeof(damage_victim), "hurtme%d", victim);
	GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victim_origin);
	int entity = CreateEntityByName("point_hurt");
	DispatchKeyValue(victim, "targetname", damage_victim);
	DispatchKeyValue(entity, "DamageTarget", damage_victim);
	DispatchKeyValue(entity, "Damage", rupture);
	DispatchSpawn(entity);
	TeleportEntity(entity, victim_origin, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entity, "Hurt", (causer > 0 && causer <= MaxClients) ? causer : -1);
	DispatchKeyValue(entity, "classname", "point_hurt");
	DispatchKeyValue(victim, "targetname", "null");
	AcceptEntityInput(entity, "Kill");
}

void KillAllWitches()
{
	int witch = -1;
	while((witch = FindEntityByClassname(witch, "witch")) != -1)
	{
		if (!IsValidEntity(witch))
		continue;	

		AcceptEntityInput(witch, "Kill");
	}
}

void CreateFires(int client)
{
	int entity = CreateEntityByName("prop_physics");
	if( entity != -1 )
	{
		SetEntityModel(entity, "models/props_junk/gascan001a.mdl");

		static float vPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecOrigin", vPos);
		vPos[2] += 10.0;
		TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(entity);

		SetEntData(entity, GetEntSendPropOffs(entity, "m_CollisionGroup"), 1, 1, true);
		SetEntPropEnt(entity, Prop_Data, "m_hPhysicsAttacker", client);
		SetEntPropFloat(entity, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());
		SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
		SetEntityRenderColor(entity, 0, 0, 0, 0);
		AcceptEntityInput(entity, "Break");
	}
}

void CreateBomb(int client)
{
	int entity = CreateEntityByName("prop_physics");
	if( entity != -1 )
	{
		SetEntityModel(entity, "models/props_junk/propanecanister001a.mdl");

		static float vPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecOrigin", vPos);
		vPos[2] += 10.0;
		TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(entity);

		SetEntData(entity, GetEntSendPropOffs(entity, "m_CollisionGroup"), 1, 1, true);
		SetEntPropEnt(entity, Prop_Data, "m_hPhysicsAttacker", client);
		SetEntPropFloat(entity, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());
		SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
		SetEntityRenderColor(entity, 0, 0, 0, 0);
		AcceptEntityInput(entity, "Break");
	}
}

void KillAllInfected()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i) == 3 && GetClientTeam(i) != 9 && IsPlayerAlive(i))
			ForcePlayerSuicide(i);
	}
}

public void Event_WeaponDrop(Event event, const char[] name, bool dontBroadcast)
{
	char weapon[64];
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	GetEventString(event, "item", weapon, sizeof(weapon));

	if (client && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2 && InfiniteAmmo[client])
	{
		if (Throwing[client] == 1)
		{
			if (StrEqual(weapon, "pipe_bomb"))
			{
				CheatCommand(client, "give pipe_bomb");
			}
			else if (StrEqual(weapon, "vomitjar"))
			{
				CheatCommand(client, "give vomitjar");
			}
			else if (StrEqual(weapon, "molotov"))
			{
				CheatCommand(client, "give molotov");
			}
			Throwing[client] = 0;
		}
	}
}

public void Event_HealSuccess(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2 && InfiniteAmmo[client])
	{	
		CreateTimer(0.1, TimerMedkit, client);
	}
}
public Action TimerMedkit(Handle timer, any client)
{
	CheatCommand(client, "give first_aid_kit");
}

public void Event_PillsUsed(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2 && InfiniteAmmo[client])
	{
		CreateTimer(0.1, TimerPills, client);
	}
}
public Action TimerPills(Handle timer, any client)
{
	CheatCommand(client, "give pain_pills");
}

public void Event_AdrenalineUsed(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2 && InfiniteAmmo[client])
	{
		CreateTimer(0.1, TimerShot, client);
	}
}
public Action TimerShot(Handle timer, any client)
{
	CheatCommand(client, "give adrenaline");
}

public void Event_DefibrillatorUsed(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2 && InfiniteAmmo[client])
	{
		CreateTimer(0.1, TimerDefib, client);
	}
}
public Action TimerDefib(Handle timer, any client)
{
	CheatCommand(client, "give defibrillator");
}

public void Event_WeaponFire(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	char weapon[64];
	event.GetString("weapon", weapon, sizeof(weapon));

	if (client && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2 && InfiniteAmmo[client])
	{
		int slot = -1;
		int clipsize;
		Throwing[client] = 0;
		if (StrEqual(weapon, "pipe_bomb") || StrEqual(weapon, "vomitjar") || StrEqual(weapon, "molotov"))
		{
			Throwing[client] = 1;
		}
		else if (StrEqual(weapon, "grenade_launcher"))
		{
			slot = 0;
			clipsize = 30;
		}
		else if (StrEqual(weapon, "pumpshotgun") || StrEqual(weapon, "shotgun_chrome"))
		{
			slot = 0;
			clipsize = 8;
		}
		else if (StrEqual(weapon, "autoshotgun") || StrEqual(weapon, "shotgun_spas"))
		{
			slot = 0;
			clipsize = 10;
		}
		else if (StrEqual(weapon, "hunting_rifle") || StrEqual(weapon, "sniper_scout"))
		{
			slot = 0;
			clipsize = 15;
		}
		else if (StrEqual(weapon, "sniper_awp"))
		{
			slot = 0;
			clipsize = 20;
		}
		else if (StrEqual(weapon, "sniper_military"))
		{
			slot = 0;
			clipsize = 30;
		}
		else if (StrEqual(weapon, "rifle_ak47"))
		{
			slot = 0;
			clipsize = 40;
		}
		else if (StrEqual(weapon, "smg") || StrEqual(weapon, "smg_silenced") || StrEqual(weapon, "smg_mp5") || StrEqual(weapon, "rifle") || StrEqual(weapon, "rifle_sg552"))
		{
			slot = 0;
			clipsize = 50;
		}
		else if (StrEqual(weapon, "rifle_desert"))
		{
			slot = 0;
			clipsize = 60;
		}
		else if (StrEqual(weapon, "rifle_m60"))
		{
			slot = 0;
			clipsize = 150;
		}
		else if (StrEqual(weapon, "pistol"))
		{
			slot = 1;
			if (GetEntProp(GetPlayerWeaponSlot(client, 1), Prop_Send, "m_isDualWielding") > 0)
				clipsize = 30;
			else
				clipsize = 15;
		}
		else if (StrEqual(weapon, "pistol_magnum"))
		{
			slot = 1;
			clipsize = 8;
		}
		else if (StrEqual(weapon, "chainsaw"))
		{
			slot = 1;
			clipsize = 30;
		}
		if (slot == 0 || slot == 1)
		{
			int weaponent = GetPlayerWeaponSlot(client, slot);
			if (weaponent > 0 && IsValidEntity(weaponent))
			{
				SetEntProp(weaponent, Prop_Send, "m_iClip1", clipsize + 1);
				if (slot == 0)
				{
					int upgradedammo = GetEntProp(weaponent, Prop_Send, "m_upgradeBitVec");
					if (upgradedammo == 1 || upgradedammo == 2 || upgradedammo == 5 || upgradedammo == 6)
					SetEntProp(weaponent, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", clipsize+1);
				}
			}
		}
	}
}

public Action OnTakeDamageGod(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(IsValidClient(client) && GodMode[client])
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action OnTakeDamageSwarm(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(IsValidClient(client) && SwarmMode[client])
	{
		char classname[32];
		GetEdictClassname(inflictor, classname, 32);
		if(StrEqual(classname, "insect_swarm", false))
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action OnTakeDamageWitch(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(IsValidClient(client) && WitchDamage[client])
	{
		char classname[64];
		GetEdictClassname(inflictor, classname, 64);
		if(StrEqual(classname, "witch", false))
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action OnTakeDamageImmune(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(IsValidClient(client) && ImmuneMode[client])
	{
		if (damagetype & DMG_BULLET || damagetype & DMG_BLAST || damagetype & DMG_BURN) //特殊伤害
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action OnTakeDamageChainsaw(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(IsValidClient(client) && ImmuneMode[client])
	{
		char sWeapon[64];
		GetEdictClassname(inflictor, sWeapon, sizeof(sWeapon));	
		if(StrEqual(sWeapon, "weapon_chainsaw", false) || StrEqual(sWeapon, "grenade_launcher_projectile", false) || StrEqual(sWeapon, "weapon_melee", false))
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}