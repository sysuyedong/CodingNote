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

配置一个新活动的步骤：
1. `config_closebeta_activity.lua` 的 `Config.CloseBetaActivity.ACT_SUB_TYPE_CONFIG` 中加指定类型活动的配置
2. 根据指定UI，在 `CustomActivityStatic.ACT_CLASS_LIST` 中加指定类型活动对应的sub_view、sub_item和标题， 菜单类型图标，菜单排序也是在 `CustomActivityStatic.lua` 中添加
3. 根据指定的 sub_view 和 sub_item ，在对应代码里面加类型判断，设置界面细节
## 神兵
模块：godWeapon  
协议：176  
神兵目前有神兵信息、培养和进阶界面
## 系统设置
## 点赞功能
## 帮派仓库