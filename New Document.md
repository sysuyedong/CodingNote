## 活动相关
模块：
```
customActivity			定制活动
closedBetaActivity		封测活动
```  
协议：331定制活动, 330封测活动  

活动类型
```
0 ~ 999										封测活动，活动数据从330协议获取
1000 ~ 1999(后台配置的活动类型 + 1000)			定制活动，活动数据从331协议获取
2000 ~ 2999									客户端手动添加的活动
```  
活动结构:
```
customActivity								活动模块
	----CustomActivityController			定制活动控制层
	----CustomActivityModel					定制活动数据层
	----CustomActivityRequire				活动require文件
	----CustomActivityStatic				活动类型、界面定制配置
	----View								主要通用界面		
		----CustomActivityBtn				菜单标签按钮
		----CustomActivityItem				活动通用奖励项
		----CustomActivitySubView			活动通用界面(有标题、内容、时间)
		----CustomActivityView				活动BaseView
	----SubView								定制界面
		----Asgard							混沌仙宫模块
		----CustomActAccuRechargeView		定制活动连续充值
		----CustomActDailyGiftView			定制活动每日礼包
		----CustomActDailyRechargeItem		定制活动今日累积充值项
		----CustomActFlowerView				定制活动限时鲜花榜
		----CustomActFollowView				定制活动关注送好礼
		----CustomActInvestView				定制活动投资
		----CustomActQuizView				封测活动科举考试
		----CustomActReputationView			定制活动五星评价
		----CustomActSevenDayView			封测活动七日首充独立界面
		----CustomActXiuXing				修行基金模块 

注：Item类的为该活动的单项自界面，在此没有单独列出
```

配置一个新活动的步骤：
1. 在`config_closebeta_activity.lua` 的 `Config.CloseBetaActivity.ACT_SUB_TYPE_CONFIG` 中加指定类型活动的配置，其中封测活动中，需要在这添加活动描述，还需要在`Config.CloseBetaActivity.title_str`中添加活动标题
2. 根据指定UI，在 `CustomActivityStatic.ACT_CLASS_LIST` 中加指定类型活动对应的sub_view、sub_item和标题， 菜单类型图标，菜单排序也是在 `CustomActivityStatic.lua` 中添加
3. 根据指定的 sub_view 和 sub_item ，在对应代码里面加类型判断，设置界面细节

### 部分细节
* 需要屏蔽活动(在活动界面中不显示),需要在收到33000或33100后，设置`obj.is_hide = true`即可  
```lua
-- 获取活动的基本数据(开关时间，活动标题，描述等)
local index = CustomActivityModel.Instance:GetIndexByType(act_type, sub_type)
local base_data = CustomActivityModel.Instance:GetIndexData(index)

-- 请求活动奖励数据
CustomActivityModel.Instance:RequestDetailData(act_type, sub_type)

-- 获取活动的奖励数据
CustomActivityModel.Instance:GetActDetailData(act_type, sub_type)

-- 获取活动标题名称
CustomActivityModel.Instance:GetActName(act_type, sub_type)

-- 获取活动时间字符串
CustomActivityModel.Instance:GetActTimeStr(act_type, sub_type, format)

-- 领取活动奖励(vo为奖励vo)
CustomActivityModel.Instance:TakeReward(act_type, sub_type, vo)
```

### 特殊活动
这些活动入口不在“精彩活动”界面，有独立的活动图标和界面，活动图标的管理在`ActivityIconManager`。这些活动都会在收到33100或33000协议后再主动请求各自的数据协议。  
基本都是采用MVC，打开界面时请求一次活动数据，收到返回时保存数据到Model中，并更新界面元素。
#### 幸运转盘
模块：luckyTurntable
协议：333
活动类型：定制活动17

#### 乐透送礼
模块：lottery
协议：31495 ~ 31497
活动类型：定制活动105

#### 七日首充
模块：customActivity/Subview/CustomActSevenDayView
封测活动21类型的独立界面，界面图标入口在`MainLeft`上，奖励数据获取和领奖等均可使用活动模块的接口

## 神兵
模块：godWeapon  
协议：176  
神兵目前有神兵信息、培养和进阶界面；配件功能暂时还没有
* 主界面的神兵展示和选择界面代码在`GodWeaponShowView`和`GodWeaponShowItem`

## 系统设置
模块：systemSeting  
```lua
SysView				-- 系统设置主界面
SysSetingView		-- 设置界面，各种屏蔽项
SysFeedbackView		-- 反馈界面
SysSuperMemberView	-- 超级会员界面
```

## 点赞功能
1. 繁体点赞功能：`SystemSetingController`协议13096和13097
2. 新马点赞礼包：在定制活动类型104，界面是`CustomActReputationView`，目前处理是打开应用商店后停留15s即可领取礼包

## 帮派仓库
模块：guild/guildwarehouse
协议：407  

以上内容，不尽详细，如有疑惑，请联系叶东(QQ: 271748017)