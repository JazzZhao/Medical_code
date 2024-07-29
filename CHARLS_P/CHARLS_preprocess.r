#biomarkers体检信息
#community社区信息（只有2011年数据）
#demographic_background个人信息
#family_information家庭成员信息
#family_transfer家庭经济关系
#individual_income 个人收入及资产
#household_income家户收入、支出及资产（2011和2013需要计算，转exp_income_wealth）
#household_roster家庭成员信息（2011），后面分成三块parent, Child, Other_HHmember
#housing_characteristics住房信息
#Exit_Interview退出信息（2013）
#Verbal_Autopsy死因信息（2013）
#Exit_Module退出问卷（2020）
#exp_income_wealth 家庭收入已统计好
#interviewer_observation访问员观察
#psu社区代码与城市对应关系
#特色模块
#health_care_and_insurance医疗保健与保险
#health_status_and_functioning健康状况与功能
#work_retirement_and_pension工作退休及养老金
#注：中间有一些跳转操作需要判断，主要是和变量缺失进行区分
# install.packages("haven")
# install.packages("readstata13",repos = "https://mirrors.sjtug.sjtu.edu.cn/cran/")
library(haven)
library(readstata13)
library(dplyr)
year = "2020"
path = "/root/r_base/CHARLS/"
# 读取文件
if(year == "2011"){
    demo <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/demographic_background.dta"))
    psu <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/psu.dta"), encoding = "GBK")
    biomarkers <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/biomarkers.dta"))
    blood <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Blood_20140429.dta"))
    health_status <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/health_status_and_functioning.dta"))
    health_care <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/health_care_and_insurance.dta"))
    exp_income <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/exp_income_wealth.dta"))
}else if(year == "2013"){
    demo <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Demographic_Background.dta"))
    psu <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/PSU.dta"), encoding = "GBK")
    biomarkers <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Biomarker.dta"))
    health_status <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Health_Status_and_Functioning.dta"))
    health_care <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Health_Care_and_Insurance.dta"))
    exp_income <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/exp_income_wealth.dta"))
}else if (year == "2015"){
    demo <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Demographic_Background.dta"))
    psu <- read_dta(paste0("/root/r_base/CHARLS/CHARLS","2013","/PSU.dta"), encoding = "GBK")
    biomarkers <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Biomarker.dta"))
    blood <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Blood.dta"))
    health_status <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Health_Status_and_Functioning.dta"))
    health_care <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Health_Care_and_Insurance.dta"))
    Household_Income <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Household_Income.dta"))
    Individual_Income <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Individual_Income.dta"))
}else if(year == '2018'){
    demo <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Demographic_Background.dta"))
    psu <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",'2013',"/PSU.dta"), encoding = "GBK")
    health_status <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Health_Status_and_Functioning.dta"))
    health_care <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Health_Care_and_Insurance.dta"))
    Household_Income <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Household_Income.dta"))
    Individual_Income <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Individual_Income.dta"))
    Cognition <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Cognition.dta"))
}else{
    demo <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Demographic_Background.dta"))
    psu <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",'2013',"/PSU.dta"), encoding = "GBK")
    health_status <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Health_Status_and_Functioning.dta"))
    Household_Income <- read_dta(paste0("CHARLS/CHARLS",year,"/Household_Income.dta"))
    Individual_Income <- read_dta(paste0("/root/r_base/CHARLS/CHARLS",year,"/Individual_Income.dta"))
}
#性别#年龄#居住地#婚姻状况
if(year == '2011'){
    data <- demo[, c('ID','householdID', 'communityID','rgender','ba002_1','be001')]
}else if(year == "2013"){
    data <- demo[, c('ID','householdID', 'communityID','ba000_w2_3','ba002_1','be001')]
}else if(year == "2015"){
    data <- demo[, c('ID','householdID', 'communityID','ba000_w2_3', 'ba004_w3_1', 'be001')]
}else if(year == "2018"){
    data <- demo[, c('ID','householdID', 'communityID','ba000_w2_3', 'ba004_w3_1', 'be001')]
}else if(year == "2020"){
    data <- demo[, c('ID','householdID', 'communityID','ba001', 'ba003_1','ba011')]
}
#性别
colnames(data)[4] <- "gender"
#年龄
colnames(data)[5] <- "born_year"
#婚姻状况
colnames(data)[6] <- "be001"
data$age <- ifelse(is.na(data$born_year), NA, as.numeric(year)-data$born_year)
data$wave <- year
#居住地
data <- merge(data, psu[,c('communityID', 'province', 'city')], by = "communityID", all.x = TRUE)

#省份、城市名称和污染物数据格式对齐
#海东地区->海东市
data$city[data$city == "海东地区"] <- "海东市"
#北京 -> 北京市
data$city[data$city == "北京"] <- "北京市"
data$province[data$province == "北京"] <- "北京市"
#哈尔滨 -> 哈尔滨市
data$city[data$city == "哈尔滨"] <- "哈尔滨市"
#天津 -> 天津市
data$city[data$city == "天津"] <- "天津市"
data$province[data$province == "天津"] <- "天津市"
#广西省 -> 广西壮族自治区
data$province[data$province == "广西省"] <- "广西壮族自治区"
#巢湖市 -> 合肥市
data$city[data$city == "巢湖市"] <- "合肥市"
#襄樊市->襄阳市
data$city[data$city == "襄樊市"] <- "襄阳市"

#身高#体重#收缩压#舒张压#脉搏
if(year == '2011'){
    biomarkers_select <- biomarkers[, c('ID','householdID', 'communityID','qi002','ql002','qa011','qa012', 'qa013')]
}else if(year == "2013"){
    biomarkers_select <- biomarkers[, c('ID','householdID', 'communityID','qi002','ql002','qa011','qa012', 'qa013')]
}else if(year == "2015"){
    biomarkers_select <- biomarkers[, c('ID','householdID', 'communityID','qi002', 'ql002', 'qa011','qa012', 'qa013')]
}
if (year == '2011' | year == '2013' | year == '2015'){
    data <- merge(data, biomarkers_select, by = c('ID','householdID', 'communityID'), all.x = TRUE)   
}else{
    # 列名列表
    new_columns <- c('qi002', 'ql002', 'qa011','qa012', 'qa013')
    # 通过循环创建新的列并赋值为NA
    for (col_name in new_columns) {
      data[[col_name]] <- NA
    }
}
#白细胞（WBC），平均红血球容积MCV,血小板,血尿素氮bun,谷氨酸glu,血肌酐crea,总胆固醇cho,甘油三酯tg,高密度脂蛋白HDL,低密度脂蛋白胆固醇LDL,C反应蛋白CRP
#糖化血红蛋白hba1c,尿酸ua,血细胞比容Hematocrit,血红蛋白hgb,胱抑素C
if(year == '2011'){
    blood <- subset(blood, select = -c(bloodweight, qc1_va003))
}else if(year == '2015'){
    blood <- blood[, c('ID', 'bl_wbc','bl_mcv','bl_plt','bl_bun','bl_glu','bl_crea','bl_cho', 'bl_tg', 'bl_hdl', 'bl_ldl','bl_crp'
                       , 'bl_hbalc','bl_ua', 'bl_hct', 'bl_hgb','bl_cysc')]
}
if(year == '2011' | year == '2015'){
    colnames(blood) <- c('ID', 'bl_wbc','bl_mcv','bl_plt','bl_bun','bl_glu','bl_crea','bl_cho', 'bl_tg', 'bl_hdl', 'bl_ldl','bl_crp'
                       , 'bl_hbalc','bl_ua', 'bl_hct', 'bl_hgb','bl_cysc')
    data <- merge(data, blood, by = c('ID'), all.x = TRUE)    
}else{
    # 列名列表
    new_columns <- c('bl_wbc','bl_mcv','bl_plt','bl_bun','bl_glu','bl_crea','bl_cho', 'bl_tg', 'bl_hdl', 'bl_ldl','bl_crp'
                       , 'bl_hbalc','bl_ua', 'bl_hct', 'bl_hgb','bl_cysc')

    # 通过循环创建新的列并赋值为NA
    for (col_name in new_columns) {
      data[[col_name]] <- NA
    }
}

#健康状况与功能:
if(year == '2018'){
    health_status$general_helth_status <-  health_status$da002
}else if(year =="2020"){
    health_status$general_helth_status <-  health_status$da001
}else{
    health_status$general_helth_status <- ifelse(is.na(health_status$da001), health_status$da002, health_status$da001)
}

#患病情况、运动情况、抽烟情况、饮酒情况
if(year == '2013'){
    names(health_status)[names(health_status) %in% c("dc006_1_s1", "dc006_1_s2", 'dc006_1_s3', 'dc006_1_s4', 'dc006_1_s5','dc006_1_s6', 
                                                     'dc006_1_s7', 'dc006_1_s8','dc006_1_s9', 'dc006_1_s10','dc006_1_s11')]<- c("dc006s1", "dc006s2", 'dc006s3', 
                                                                         'dc006s4', 'dc006s5','dc006s6', 'dc006s7','dc006s8', 'dc006s9', 'dc006s10', 'dc006s11')
}else if(year == "2018"){
    names(Cognition)[names(Cognition) %in% c("dc001_w4", "dc006_w4", 
                                                     'dc003_w4', 'dc005_w4', 'dc002_w4')]<- c("dc001s1", "dc001s2",'dc001s3','dc002','dc003') 
    names(Cognition)[names(Cognition) %in% c("dc014_w4_1_1", "dc014_w4_2_1", 
                                                     'dc014_w4_3_1', 'dc014_w4_4_1', 'dc014_w4_5_1')]<- c("dc019", "dc020", 
                                                                                              'dc021', 'dc022', 'dc023')
    names(Cognition)[names(Cognition) %in% c("dc028_w4_s1", "dc028_w4_s2", 'dc028_w4_s3', 'dc028_w4_s4', 'dc028_w4_s5','dc028_w4_s6', 
                                                     'dc028_w4_s7', 'dc028_w4_s8', 
                                                     'dc028_w4_s9', 'dc028_w4_s10', 
                                                     'dc028_w4_s11')]<- c("dc006s1", "dc006s2", 'dc006s3', 
                                                                         'dc006s4', 'dc006s5','dc006s6', 'dc006s7', 
                                                                         'dc006s8', 'dc006s9', 'dc006s10', 'dc006s11')
    names(Cognition)[names(Cognition) %in% c("dc047_w4_s1", "dc047_w4_s2", 'dc047_w4_s3', 'dc047_w4_s4', 'dc047_w4_s5','dc047_w4_s6', 
                                                 'dc047_w4_s7', 'dc047_w4_s8', 
                                                 'dc047_w4_s9', 'dc047_w4_s10', 
                                                 'dc047_w4_s11', 'dc024_w4')]<- c("dc027s1", "dc027s2", 'dc027s3', 
                                                                     'dc027s4', 'dc027s5','dc027s6', 'dc027s7', 
                                                                     'dc027s8', 'dc027s9', 'dc027s10', 'dc027s11','dc025')
}else if (year == "2020"){
    #词语记忆，第一遍                                                                            
    names(health_status)[names(health_status) %in% c("dc012_s1", "dc012_s2", 'dc012_s3', 'dc012_s4', 'dc012_s5','dc012_s6','dc012_s7', 'dc012_s8','dc012_s9', 'dc012_s10', 
                                                     'dc012_s11')]<- c("dc006s1", "dc006s2", 'dc006s3','dc006s4', 'dc006s5','dc006s6', 'dc006s7','dc006s8', 'dc006s9', 'dc006s10', 'dc006s11')
    #词语记忆，第二遍   
    names(health_status)[names(health_status) %in% c("dc028_s1", "dc028_s2", 'dc028_s3', 'dc028_s4', 'dc028_s5','dc028_s6','dc028_s7', 'dc028_s8','dc028_s9', 'dc028_s10', 
                                                     'dc028_s11')]<- c("dc027s1", "dc027s2", 'dc027s3','dc027s4', 'dc027s5','dc027s6', 'dc027s7', 
                                                     'dc027s8', 'dc027s9', 'dc027s10', 'dc027s11')
}

#日常生活活动能力(ADL)：包括上厕所、吃饭、穿衣、控制大小便、上下床、洗澡6个条目，若其中有一项需要他人帮助，则视为ADL失能。>0为失能
if (year == "2020"){
    health_status$db010_score <- ifelse(health_status$db001 > 2, 1, 0)
    health_status$db011_score <- ifelse(health_status$db003 > 2, 1, 0)
    health_status$db012_score <- ifelse(health_status$db005 > 2, 1, 0)                                         
    health_status$db013_score <- ifelse(health_status$db007 > 2, 1, 0)                                         
    health_status$db014_score <- ifelse(health_status$db009 > 2, 1, 0)                                         
    health_status$db015_score <- ifelse(health_status$db011 > 2, 1, 0)    
}else{
    health_status$db010_score <- ifelse(health_status$db010 > 2, 1, 0)
    health_status$db011_score <- ifelse(health_status$db011 > 2, 1, 0)
    health_status$db012_score <- ifelse(health_status$db012 > 2, 1, 0)                                         
    health_status$db013_score <- ifelse(health_status$db013 > 2, 1, 0)                                         
    health_status$db014_score <- ifelse(health_status$db014 > 2, 1, 0)                                         
    health_status$db015_score <- ifelse(health_status$db015 > 2, 1, 0)
}
health_status$ADL_score <- apply(health_status[,c('db010_score','db011_score','db012_score', 'db013_score', 'db014_score'
                                      ,'db015_score')], 1, function(x) sum(x))                                         
                                         
#IADL：包括做家务、做饭、购物、吃药、管理财务5个条目，若其中有一项需要他人帮助，则视为IADL失能。
if (year =='2020'){
    health_status$db016_score <- ifelse(health_status$db012 > 2, 1, 0)
    health_status$db017_score <- ifelse(health_status$db014 > 2, 1, 0)
    health_status$db018_score <- ifelse(health_status$db016 > 2, 1, 0)                                         
    health_status$db019_score <- ifelse(health_status$db020 > 2, 1, 0)                                         
    health_status$db020_score <- ifelse(health_status$db022 > 2, 1, 0) 
}else{
    health_status$db016_score <- ifelse(health_status$db016 > 2, 1, 0)
    health_status$db017_score <- ifelse(health_status$db017 > 2, 1, 0)
    health_status$db018_score <- ifelse(health_status$db018 > 2, 1, 0)                                         
    health_status$db019_score <- ifelse(health_status$db019 > 2, 1, 0)                                         
    health_status$db020_score <- ifelse(health_status$db020 > 2, 1, 0) 
}
health_status$IADL_score <- apply(health_status[,c('db016_score','db017_score','db018_score', 'db019_score', 'db020_score')], 1, function(x) sum(x))   

if(year == "2020"){
    #2020年疾病的label和其他年份不一样，需要处理
    # 指定需要处理的列
    columns_to_process <- c('da002_1_', 'da002_2_','da002_3_'
                            ,'da002_4_','da002_5_','da002_6_','da002_7_','da002_8_','da002_9_','da002_10_','da002_11_'
                            ,'da002_12_','da002_13_','da002_14_','da002_15_')
    # 使用 mutate_at() 对指定列进行处理
    health_status <- health_status %>%
        mutate_at(vars(columns_to_process), ~ case_when(
            . == 99 ~ 2,
            . %in% 1:3 ~ 1,
            TRUE ~ NA_real_
        ))
    # 2020年把帕金森和记忆病症分开，需要和以前对齐
    # 使用 mutate() 和 case_when() 实现条件逻辑处理
    health_status <- health_status %>%
    mutate(
        da002_12_ = case_when(
        da002_12_ == 1 | da002_13_ == 1 ~ 1,
        da002_12_ == 2 & da002_13_ == 2 ~ 2,
        da002_12_ == 2 & is.na(da002_13_) | is.na(da002_12_) & da002_13_ == 2 ~ 2,
        is.na(da002_12_) & is.na(da002_13_) ~ NA_real_,
        TRUE ~ NA_real_  # 预防万一，其余情况下设为NA
        )
    )
    health_status_select <- health_status[, c('ID','householdID', 'communityID', 'general_helth_status'
                                   ,'ADL_score', 'IADL_score', 'da002_1_', 'da002_2_','da002_3_'
                                   ,'da002_4_','da002_5_','da002_6_','da002_7_','da002_8_','da002_9_','da002_10_','da002_11_'
                                   ,'da002_12_','da002_14_','da002_15_','da032_1_','da032_2_', 'da032_3_'
                                   ,'da033_1_','da033_2_','da033_3_','da034_1_','da034_2_','da034_3_','da035_1_','da035_2_','da035_3_'
                                    ,'da036_1_','da036_2_','da036_3_', 'da046','da047','da050_1'
                                   ,'da051')]
    health_status_select$da051 <- ifelse(health_status_select$da051==1, 3, ifelse(health_status_select$da051==3, 1, health_status_select$da051))
}else{
    health_status_select <- health_status[, c('ID','householdID', 'communityID', 'general_helth_status'
                                   ,'ADL_score', 'IADL_score', 'da007_1_', 'da007_2_','da007_3_'
                                   ,'da007_4_','da007_5_','da007_6_','da007_7_','da007_8_','da007_9_','da007_10_','da007_11_'
                                   ,'da007_12_','da007_13_','da007_14_','da051_1_','da051_2_', 'da051_3_'
                                   ,'da052_1_','da052_2_','da052_3_','da053_1_','da053_2_','da053_3_','da054_1_','da054_2_','da054_3_'
                                    ,'da055_1_','da055_2_','da055_3_', 'da059','da061','da063'
                                   ,'da069')]
}
colnames(health_status_select) <- c('ID', 'householdID', 'communityID', 'general_helth_status'
                            ,'ADL_score', 'IADL_score', 'Hypertension','Dyslipidemia','Disabetes_or_High_Blood_Sugar'
                             ,'Cancer_or_Malignant_Tumor','Chronic_Lung_Diseases', 'Liver_Disease', 'Heart_Problems', 'Stroke', ' Kidney_Diease'
                             ,'Stomach_or_Other_Digestive_Disease', 'Emotional_Nervous_or_Psychiatric_Problems', ' Memory_Related_Disease',' Arthritis_or_Rheumatism'
                             ,'Asthma', 'Vigorous_Activities', 'Moderate_Physical_Effort','Walking'
                             ,'Vigorous_Activities_day', 'Moderate_Physical_Effort_day','Walking_day','Vigorous_Activities_2h', 'Moderate_Physical_Effort_2h','Walking_2h'
                             ,'Vigorous_Activities_30m', 'Moderate_Physical_Effort_30m','Walking_30m','Vigorous_Activities_4h', 'Moderate_Physical_Effort_4h','Walking_4h'
                             ,'Smoke', 'Smoke_still','Number_Cigarettes','Drink')
data <- merge(data, health_status_select, by = c('ID', 'householdID', 'communityID'), all.x = TRUE)  

if(year =="2018"){
    health_status = Cognition
}
#计算认知功能得分，分成三部分：电话问卷10分，词语回忆10分、画图1分
if(year == "2020"){
    health_status$dc001s1_score <- ifelse(is.na(health_status$dc001), 0, ifelse(health_status$dc001 == 1, 1, 0))
    health_status$dc001s2_score <- ifelse(is.na(health_status$dc005), 0, ifelse(health_status$dc005 == 2, 1, 0))
    health_status$dc001s3_score <- ifelse(is.na(health_status$dc003), 0, ifelse(health_status$dc003 == 3, 1, 0))
    health_status$dc002_score <- ifelse(is.na(health_status$dc004), 0, ifelse(health_status$dc004 == 1, 1, 0))
    health_status$dc003_score <- ifelse(is.na(health_status$dc002), 0, ifelse(health_status$dc002 == 1, 1, 0))
    health_status$dc019_score <- ifelse(is.na(health_status$dc007_1), 0, ifelse(health_status$dc007_1 == 93, 1, 0))
    health_status$dc020_score <- ifelse(is.na(health_status$dc007_2), 0, ifelse(health_status$dc007_2 == 86, 1, 0))
    health_status$dc021_score <- ifelse(is.na(health_status$dc007_3), 0, ifelse(health_status$dc007_3 == 79, 1, 0))
    health_status$dc022_score <- ifelse(is.na(health_status$dc007_4), 0, ifelse(health_status$dc007_4 == 72, 1, 0))
    health_status$dc023_score <- ifelse(is.na(health_status$dc007_5), 0, ifelse(health_status$dc007_5 == 65, 1, 0))
}else{
    health_status$dc001s1_score <- ifelse(is.na(health_status$dc001s1), 0, ifelse(health_status$dc001s1 == 1, 1, 0))
    health_status$dc001s2_score <- ifelse(is.na(health_status$dc001s2), 0, ifelse(health_status$dc001s2 == 2, 1, 0))
    health_status$dc001s3_score <- ifelse(is.na(health_status$dc001s3), 0, ifelse(health_status$dc001s3 == 3, 1, 0))
    health_status$dc002_score <- ifelse(is.na(health_status$dc002), 0, ifelse(health_status$dc002 == 1, 1, 0))
    health_status$dc003_score <- ifelse(is.na(health_status$dc003), 0, ifelse(health_status$dc003 == 1, 1, 0))
    health_status$dc019_score <- ifelse(is.na(health_status$dc019), 0, ifelse(health_status$dc019 == 93, 1, 0))
    health_status$dc020_score <- ifelse(is.na(health_status$dc020), 0, ifelse(health_status$dc020 == 86, 1, 0))
    health_status$dc021_score <- ifelse(is.na(health_status$dc021), 0, ifelse(health_status$dc021 == 79, 1, 0))
    health_status$dc022_score <- ifelse(is.na(health_status$dc022), 0, ifelse(health_status$dc022 == 72, 1, 0))
    health_status$dc023_score <- ifelse(is.na(health_status$dc023), 0, ifelse(health_status$dc023 == 65, 1, 0))
}
health_status$Cognitive_functioning <- apply(health_status[,c('dc001s1_score','dc001s2_score','dc001s3_score', 'dc002_score', 'dc003_score'
                                      ,'dc019_score','dc020_score','dc021_score','dc022_score','dc023_score')], 1, function(x) sum(x))

#词语记忆
health_status$dc006s1_score <- ifelse(is.na(health_status$dc006s1), 0, ifelse(health_status$dc006s1 == 1, 1, 0))
health_status$dc006s2_score <- ifelse(is.na(health_status$dc006s2), 0, ifelse(health_status$dc006s2 == 2, 1, 0))
health_status$dc006s3_score <- ifelse(is.na(health_status$dc006s3), 0, ifelse(health_status$dc006s3 == 3, 1, 0))
health_status$dc006s4_score <- ifelse(is.na(health_status$dc006s4), 0, ifelse(health_status$dc006s4 == 4, 1, 0))
health_status$dc006s5_score <- ifelse(is.na(health_status$dc006s5), 0, ifelse(health_status$dc006s5 == 5, 1, 0))
health_status$dc006s6_score <- ifelse(is.na(health_status$dc006s6), 0, ifelse(health_status$dc006s6 == 6, 1, 0))                                             
health_status$dc006s7_score <- ifelse(is.na(health_status$dc006s7), 0, ifelse(health_status$dc006s7 == 7, 1, 0))
health_status$dc006s8_score <- ifelse(is.na(health_status$dc006s8), 0, ifelse(health_status$dc006s8 == 8, 1, 0))
health_status$dc006s9_score <- ifelse(is.na(health_status$dc006s9), 0, ifelse(health_status$dc006s9 == 9, 1, 0))                                             
health_status$dc006s10_score <- ifelse(is.na(health_status$dc006s10), 0, ifelse(health_status$dc006s10 == 10, 1, 0))                                             
health_status$dc006s11_score <- ifelse(is.na(health_status$dc006s11), 0, ifelse(health_status$dc006s11 == 11, 1, 0))
health_status$dc027s1_score <- ifelse(is.na(health_status$dc027s1), 0, ifelse(health_status$dc027s1 == 1, 1, 0))
health_status$dc027s2_score <- ifelse(is.na(health_status$dc027s2), 0, ifelse(health_status$dc027s2 == 2, 1, 0))
health_status$dc027s3_score <- ifelse(is.na(health_status$dc027s3), 0, ifelse(health_status$dc027s3 == 3, 1, 0))
health_status$dc027s4_score <- ifelse(is.na(health_status$dc027s4), 0, ifelse(health_status$dc027s4 == 4, 1, 0))
health_status$dc027s5_score <- ifelse(is.na(health_status$dc027s5), 0, ifelse(health_status$dc027s5 == 5, 1, 0))
health_status$dc027s6_score <- ifelse(is.na(health_status$dc027s6), 0, ifelse(health_status$dc027s6 == 6, 1, 0))                                             
health_status$dc027s7_score <- ifelse(is.na(health_status$dc027s7), 0, ifelse(health_status$dc027s7 == 7, 1, 0))
health_status$dc027s8_score <- ifelse(is.na(health_status$dc027s8), 0, ifelse(health_status$dc027s8 == 8, 1, 0))
health_status$dc027s9_score <- ifelse(is.na(health_status$dc027s9), 0, ifelse(health_status$dc027s9 == 9, 1, 0))                                             
health_status$dc027s10_score <- ifelse(is.na(health_status$dc027s10), 0, ifelse(health_status$dc027s10 == 10, 1, 0))                                             
health_status$dc027s11_score <- ifelse(is.na(health_status$dc027s11), 0, ifelse(health_status$dc027s11 == 11, 1, 0))
health_status$remenber_functioning <- apply(health_status[,c('dc006s1_score','dc006s2_score','dc006s3_score', 'dc006s4_score', 'dc006s5_score'
                                      ,'dc006s6_score','dc006s7_score','dc006s8_score','dc006s9_score','dc006s10_score'
                                    ,'dc006s11_score','dc027s1_score','dc027s2_score','dc027s3_score','dc027s4_score','dc027s5_score'
                                    ,'dc027s6_score','dc027s7_score','dc027s8_score','dc027s9_score','dc027s10_score','dc027s11_score')], 1, function(x) sum(x)/2)
#画图
if(year == "2020"){
    health_status$draw_score <- ifelse(is.na(health_status$dc009), 0, ifelse(health_status$dc009 == 1, 1, 0))
}else{
    health_status$draw_score <- ifelse(is.na(health_status$dc025), 0, ifelse(health_status$dc025 == 1, 1, 0))
}

#心理得分
if(year == '2020'){
    health_status$dc009_score <- health_status$dc016-1
    health_status$dc010_score <- health_status$dc017-1
    health_status$dc011_score <- health_status$dc018-1
    health_status$dc012_score <- health_status$dc019-1                                            
    health_status$dc013_score <- 4 - health_status$dc020                                        
    health_status$dc014_score <- health_status$dc021-1                                            
    health_status$dc015_score <- health_status$dc022-1                                            
    health_status$dc016_score <- 4 - health_status$dc023
    health_status$dc017_score <- health_status$dc024-1                                            
    health_status$dc018_score <- health_status$dc025-1 
}else{
    health_status$dc009_score <- health_status$dc009-1
    health_status$dc010_score <- health_status$dc010-1
    health_status$dc011_score <- health_status$dc011-1
    health_status$dc012_score <- health_status$dc012-1                                            
    health_status$dc013_score <- 4 - health_status$dc013                                        
    health_status$dc014_score <- health_status$dc014-1                                            
    health_status$dc015_score <- health_status$dc015-1                                            
    health_status$dc016_score <- 4 - health_status$dc016
    health_status$dc017_score <- health_status$dc017-1                                            
    health_status$dc018_score <- health_status$dc018-1 
}
                                           
health_status$psychiatric_score <- apply(health_status[,c('dc009_score','dc010_score','dc011_score', 'dc012_score', 'dc013_score'
                                      ,'dc014_score','dc015_score','dc016_score','dc017_score','dc018_score')], 1, function(x) sum(x))

health_status <- health_status[, c('ID','householdID', 'communityID','Cognitive_functioning','remenber_functioning'
                                   ,'draw_score','psychiatric_score')] 
colnames(health_status) <- c('ID', 'householdID', 'communityID','Cognitive_functioning','remenber_functioning'
                            ,'draw_score','psychiatric_score')
data <- merge(data, health_status, by = c('ID', 'householdID', 'communityID'), all.x = TRUE)  

#住院情况
if (year != '2020'){
    health_care =  health_care[, c('ID','householdID', 'communityID', 'ee003', 'ee004')]
    colnames(health_care) <- c('ID','householdID', 'communityID', 'received_inpatient_care',"Frequency_one_year")
    data <- merge(data, health_care, by = c('ID', 'householdID', 'communityID'), all.x = TRUE)  
}else{
    data['received_inpatient_care'] <- NA
    data['Frequency_one_year'] <- NA
}

#个人收入情况
if (year == '2011' | year == '2013'){
    exp_income =  exp_income[, c('ID','householdID', 'communityID','INDV_INCOME')]
    data <- merge(data, exp_income, by = c('ID', 'householdID', 'communityID'), all.x = TRUE)  
}else {
    Individual_Income$INDV_INCOME <- ifelse(Individual_Income$ga001==2, 0, Individual_Income$ga002)
    data <- merge(data, Individual_Income[,c('ID','householdID', 'communityID','INDV_INCOME')], by = c('ID', 'householdID', 'communityID'), all.x = TRUE)
    # Household_Income$INCOME_TOTAL <- apply(Household_Income[,c('ga006_1_1_','ga006_1_2_','ga006_1_3_'
    #                                         ,'ga006_1_4_','ga006_1_5_','ga006_1_6_','ga006_1_7_','ga006_1_8_','ga006_1_9_','ga006_1_10_')], 1, function(x) sum(x, na.rm = TRUE))
}
write.csv(data, file = paste0(path, "result", year, ".csv"), row.names = FALSE)


#合并
csv_files <- list.files(path = path, pattern = "\\.csv$", recursive = TRUE, full.names = TRUE)
df_combined <- NA
# 确保读取文件的路径是完整的
if (length(csv_files) > 0) {
  for (file in csv_files) {
    # 读取每个.csv文件
    data <- read.csv(file, stringsAsFactors = FALSE)
    print(ncol(data))
    if (length(df_combined) == 0){
      df_combined <- data
    }else{
      df_combined <- rbind(data, df_combined)
    }
    print(paste("Read file:", file))
  }
}
write.csv(df_combined, file = paste0("/root/r_base/CHARLS/", "result_all", ".csv"), row.names = FALSE)
