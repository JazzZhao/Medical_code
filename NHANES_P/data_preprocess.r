# NHANES
# install.packages("caret", repos="https://mirrors.ustc.edu.cn/CRAN/")
library(caret)
library(nhanesA)
library(knitr)
library(tidyverse)
library(plyr)
library(dplyr)
library(foreign)

path = "NHANES/2017-2018/"
year = "_J"
# year_ = "2001-2002"

DEMO <- read.xport(paste0(path , "DEMO",year,".XPT"))

#选取数据发布号、样本人员的访谈和检查状态、性别、年龄、种族、出生地
#社会经济地位数据：家庭 PIR、家庭年度收入
if(year =="" || year == "_B" || year == "_C" || year == "_D"){
  DEMO <- DEMO %>% select(SEQN, SDDSRVYR, RIDSTATR, RIAGENDR, RIDAGEYR, RIDRETH1, DMDBORN, INDFMPIR, INDFMINC)
}else if(year =="_E" || year == "_F"){
  DEMO <- DEMO %>% select(SEQN, SDDSRVYR, RIDSTATR, RIAGENDR, RIDAGEYR, RIDRETH1, DMDBORN2, INDFMPIR, INDHHIN2)
}else{
  DEMO <- DEMO %>% select(SEQN, SDDSRVYR, RIDSTATR, RIAGENDR, RIDAGEYR, RIDRETH1, DMDBORN4, INDFMPIR, INDHHIN2)
}
print(names(DEMO)[9])
names(DEMO)[7] <- "DMDBORN"
names(DEMO)[9] <- "INDFMINC"

# #收入
# if(year=="_E" | year=="_F" | year=="_H" | year=="_G" |year=="_I" | year=="_J"){
#   INQ <- read.xport(paste0(path, "INQ",year,".XPT"))
#   data <- join_all(list(data, INQ), by = "SEQN", type = "left")
# }


#重量、站立高度、体重指数
BMX <- read.xport(paste0(path, "BMX",year,".XPT"))
BMX <- BMX %>% select(SEQN, BMXWT , BMXHT , BMXBMI )

data <- join_all(list(DEMO, BMX), by = "SEQN", type = "left")

#收缩压平均值、舒张压平均值、60 秒心率
BPX <- read.xport(paste0(path, "BPX",year,".XPT"))
BPX <- BPX %>% select(SEQN, BPXSY1, BPXDI1, BPXCHR)
data <- join_all(list(data, BPX), by = "SEQN", type = "left")

#空腹血浆葡萄糖
if(year ==""){
  LAB10AM <- read.xport(paste0(path, "LAB10AM",year,".XPT"))
  LAB10AM <- LAB10AM %>% select(SEQN, LBXGLUSI )
}else if (year == "_B"){
  LAB10AM <- read.xport(paste0(path, "L10AM",year,".XPT"))
  LAB10AM <- LAB10AM %>% select(SEQN, LBXGLUSI )
}else if (year == "_C"){
  LAB10AM <- read.xport(paste0(path, "L10AM",year,".XPT"))
  LAB10AM <- LAB10AM %>% select(SEQN, LBDGLUSI)
}else{
  LAB10AM <- read.xport(paste0(path, "GLU",year,".XPT"))
  LAB10AM <- LAB10AM %>% select(SEQN, LBDGLUSI)
}
names(LAB10AM)[2] <- "LBDGLUSI"

data <- join_all(list(data, LAB10AM), by = "SEQN", type = "left")

#尿白蛋白
if (year == ""){
  LAB16 <- read.xport(paste0(path, "LAB16",year,".XPT"))
}else if(year == "_B" | year == "_C"){
  LAB16 <- read.xport(paste0(path, "L16",year,".XPT"))
}else{
  LAB16 <- read.xport(paste0(path, "ALB_CR",year,".XPT"))
}
LAB16 <- LAB16 %>% select(SEQN, URXUMA)

data <- join_all(list(data, LAB16), by = "SEQN", type = "left")

#血常规：白细胞计数 （SI）1000 个细胞/uL、淋巴细胞计数、单核细胞数、红细胞计数 SI（百万细胞/uL）、血红蛋白 （g/dL）、血小板计数 （1000 个细胞/uL）
#、嗜酸性粒细胞数、嗜碱性粒细胞数、Segmented neutrophils number（分叶中性粒细胞数量）1000 细胞/uL
if (year == ""){
  LAB25 <- read.xport(paste0(path, "LAB25",year,".XPT"))
}else if(year == "_B" | year == "_C"){
  LAB25 <- read.xport(paste0(path, "L25",year,".XPT"))
}else{
  LAB25 <- read.xport(paste0(path, "CBC",year,".XPT"))
}
LAB25 <- LAB25 %>% select(SEQN, LBXWBCSI, LBDLYMNO, LBDMONO, LBXRBCSI, LBXHGB, LBXPLTSI, LBDEONO, LBDBANO, LBDNENO)
#计算炎症指标
LAB25$SIRI <- LAB25$LBDNENO*LAB25$LBDMONO/LAB25$LBDLYMNO
LAB25$SII <- LAB25$LBXPLTSI*LAB25$LBDNENO/LAB25$LBDLYMNO

data <- join_all(list(data, LAB25), by = "SEQN", type = "left")

#血脂：甘油三酯(mmol/L))、低密度脂蛋白胆固醇(mmol/L))、总胆固醇、高密度脂蛋白胆固醇（mmol/L）、总胆固醇、甘油三酯
#肾功能：血尿素氮、肌酐
#肝功能:ALT、AST、总胆红素
if (year == ""){
  LAB13AM <- read.xport(paste0(path, "LAB13AM",year,".XPT"))
}else if(year == "_B" | year == "_C"){
  LAB13AM <- read.xport(paste0(path, "L13AM",year,".XPT"))
}else{
  LAB13AM <- read.xport(paste0(path, "TRIGLY",year,".XPT"))
}
LAB13AM <- LAB13AM %>% select(SEQN, LBDTRSI, LBDLDLSI)
data <- join_all(list(data, LAB13AM), by = "SEQN", type = "left")

if(year ==""){
  LAB13 <- read.xport(paste0(path, "LAB13",year,".XPT"))
}else if(year == "_B" | year == "_C"){
  LAB13 <- read.xport(paste0(path, "L13",year,".XPT"))
}else{
  LAB13 <- read.xport(paste0(path, "TCHOL",year,".XPT"))
}
if(year=="" | year=="_B"){
  LAB13 <- LAB13 %>% select(SEQN, LBDTCSI, LBDHDLSI)
}else if(year == "_C"){   #Direct HDL-Cholesterol 
  LAB13 <- LAB13 %>% select(SEQN, LBDTCSI, LBDHDDSI)
}else{
  LAB13 <- LAB13 %>% select(SEQN, LBDTCSI)
  HDL <- read.xport(paste0(path, "HDL",year,".XPT"))
  HDL <- HDL %>% select(SEQN, LBDHDDSI)
  LAB13 <- join_all(list(LAB13, HDL), by = "SEQN", type = "left")
}
names(LAB13)[3] <- "LBDHDDSI"
data <- join_all(list(data, LAB13), by = "SEQN", type = "left")

#计算炎症指标
data$MHR <- data$LBDMONO/data$LBDHDDSI
data$NHR <- data$LBDNENO/data$LBDHDDSI
data$PHR <- data$LBXPLTSI/data$LBDHDDSI
data$LHR <- data$LBDLYMNO /data$LBDHDDSI

# 同型半胱氨酸(1999-2006),其他年份为空
if(year == "" || year == "_D" || year == "_C" || year == "_B"){
  if(year == ""){
    LAB06 <- read.xport(paste0(path, "LAB06",year,".XPT"))
    LAB06 <- LAB06 %>% select(SEQN, LBXHCY)
  }else if(year == "_B"){
    LAB06 <- read.xport(paste0(path, "L06",year,".XPT"))
    LAB06 <- LAB06 %>% select(SEQN, LBDHCY)
  }else if(year == "_C"){
    LAB06 <- read.xport(paste0(path, "L06MH",year,".XPT"))
    LAB06 <- LAB06 %>% select(SEQN, LBXHCY)
  }else{
    LAB06 <- read.xport(paste0(path, "HCY",year,".XPT"))
    LAB06 <- LAB06 %>% select(SEQN, LBXHCY)
  }
  names(LAB06)[2] <- "LBXHCY"
  data <- join_all(list(data, LAB06), by = "SEQN", type = "left")
}else{
  data$LBXHCY <- NA
}

if(year == ""){
  LAB18 <- read.xport(paste0(path, "LAB18",year,".XPT"))
}else if(year == "_B" || year == "_C"){
  LAB18 <- read.xport(paste0(path, "L40",year,".XPT"))
}else{
  LAB18 <- read.xport(paste0(path, "BIOPRO",year,".XPT"))
}
LAB18 <- LAB18 %>% select(SEQN, LBDSCHSI, LBDSTRSI, LBDSBUSI, LBDSCRSI, LBXSATSI, LBXSASSI, LBDSTBSI )
data <- join_all(list(data, LAB18), by = "SEQN", type = "left")

#甲状腺功能：促甲状腺激素
if(year == "" || year == "_B" ||year =="_E" || year =="_F" || year =="_G"){
  if(year == ""){
    LAB18T4 <- read.xport(paste0(path, "LAB18T4",year,".XPT"))
    LAB18T4 <- LAB18T4 %>% select(SEQN, LBXTSH)
  }else if(year == "_B"){
    LAB18T4 <- read.xport(paste0(path, "L40T4",year,".XPT"))
    LAB18T4 <- LAB18T4 %>% select(SEQN, LBXTSH)
  }else if (year =="_E" || year =="_F" || year =="_G"){
    LAB18T4 <- read.xport(paste0(path, "THYROD",year,".XPT"))
    LAB18T4 <- LAB18T4 %>% select(SEQN, LBXTSH1)
  }
  names(LAB18T4)[2] <- "LBXTSH"
  data <- join_all(list(data, LAB18T4), by = "SEQN", type = "left")
}else{
  data$LBXTSH <- NA
}

#甲状腺功能：游离甲状腺素(2007-2012)
if(year == "_E" || year == "_F" || year == "_G"){
  THYROD <- read.xport(paste0(path, "THYROD",year,".XPT"))
  THYROD <- THYROD %>% select(SEQN, LBDT4FSI)
  data <- join_all(list(data, THYROD), by = "SEQN", type = "left")
}else{
  data$LBDT4FSI <- NA
}

#吸烟史
#成人 20+
SMQ <- read.xport(paste0(path, "SMQ",year,".XPT"))
SMQ <- SMQ %>% select(SEQN, SMQ020, SMD030, SMQ040, SMQ050Q, SMQ050U, SMD057)
data <- join_all(list(data, SMQ), by = "SEQN", type = "left")

#饮酒史 20+
ALQ <- read.xport(paste0(path, "ALQ",year,".XPT"))
if(year == "" || year == "_B" ||year =="_E" || year =="_F" || year =="_C" || year =="_D"){
  ALQ <- ALQ %>% select(SEQN, ALQ150, ALQ130)
}else{
  ALQ <- ALQ %>% select(SEQN, ALQ151, ALQ130)
}
names(ALQ)[2] <- "ALQ150"
data <- join_all(list(data, ALQ), by = "SEQN", type = "left")

#饮食习惯
DBQ <- read.xport(paste0(path, "DBQ",year,".XPT"))
if(year == "" || year == "_B" ||year =="_E" || year =="_C" || year =="_D"){
  if(year == ""){
    DBQ <- DBQ %>% select(SEQN, DBQ010, DBD030, DBD040, DBD050, DBD060, DBQ070A, DBQ070B, DBQ070C, DBQ390, DBD400, DBD410, DBQ420, 
        DBQ070D, DBD195, DBQ220A, DBQ220B, DBQ220C, DBQ220D, DBD235A, DBD235B, DBD235C, DBQ300, DBQ330, DBD360, DBD370, DBD380)
  }else if (year == "_B"){
    DBQ <- DBQ %>% select(SEQN, DBQ010, DBD030, DBD040, DBD050, DBD060, DBD071A, DBD071B, DBD071C, DBQ390, DBQ400, DBD411, DBD421,
        DBD071D, DBD196, DBD221A, DBD221B, DBD221C, DBD221D, DBD235AE, DBD235BE, DBD235CE, DBD301, DBQ330, DBQ360, DBQ370, DBD381)
  }else if(year == "_C"){
    DBQ <- DBQ %>% select(SEQN, DBQ010, DBD030, DBD040, DBD050, DBD060, DBQ071A, DBQ071B, DBQ071C, DBQ390, DBQ400, DBD411, DBQ421,
        DBQ071D, DBD197, DBQ221A, DBQ221B, DBQ221C, DBQ221D, DBQ235A, DBQ235B, DBQ235C, DBQ301, DBQ330, DBQ360, DBQ370, DBD381)
  }else if(year == "_D" || year == "_E"){
    DBQ <- DBQ %>% select(SEQN, DBQ010, DBD030, DBD040, DBD050, DBD060, DBD072A, DBD072B, DBD072C, DBQ390, DBQ400, DBD411, DBQ421,
        DBD072D, DBQ197, DBD222A, DBD222B, DBD222C, DBD222D, DBQ235A, DBQ235B, DBQ235C, DBQ301, DBQ330, DBQ360, DBQ370, DBD381)
  }
}else{
  DBQ <- DBQ %>% select(SEQN, DBQ010, DBD030, DBD041, DBD050, DBD061, DBQ073A, DBQ073B, DBQ073C, DBQ390, DBQ400, DBD411, DBQ421,
      DBQ073D, DBQ197, DBQ223A, DBQ223B, DBQ223C, DBQ223D, DBQ235A, DBQ235B, DBQ235C, DBQ301, DBQ330, DBQ360, DBQ370, DBD381)
}
names(DBQ) <- c("SEQN", "DBQ010", "DBD030", "DBD041", "DBD050", "DBD061", "DBQ073A", "DBQ073B", "DBQ073C", "DBQ390", "DBQ400", "DBD411", "DBQ421",
      "DBQ073D", "DBQ197", "DBQ223A", "DBQ223B", "DBQ223C", "DBQ223D", "DBQ235A", "DBQ235B", "DBQ235C", "DBQ301", "DBQ330", "DBQ360", "DBQ370", "DBD381") 
data <- join_all(list(data, DBQ), by = "SEQN", type = "left")

#体力活动
PAQ <- read.xport(paste0(path, "PAQ",year,".XPT"))
PAQ[is.na(PAQ)] <- 0
if(year == ""){
  PAQ_s <- PAQ %>% select(SEQN, PAD020, PAQ100, PAQ180, PAD440, PAQ480, PAQ560, PAD570, PAQ580)
  PAQ_s$PAD020 <- ifelse(PAQ_s$PAD020 == 1, 4, 0)
  PAQ_s$PAQ100 <- ifelse(PAQ_s$PAQ100 == 1, 4.5, 0)
  PAQ_s$PAQ180 <- ifelse(PAQ_s$PAQ180 == 1, 1.4, ifelse(PAQ_s$PAQ180 == 2, 1.5, ifelse(PAQ_s$PAQ180 == 3, 1.6, ifelse(PAQ_s$PAQ180 == 4, 1.8, 0))))
  PAQ_s$PAD440 <- ifelse(PAQ_s$PAD440 == 1, 4, 0)
  PAQ_s$PAQ480 <- ifelse(PAQ_s$PAQ480 < 6, 1.2 * PAQ_s$PAQ480, 0)
  PAQ_s$PAQ560 <- ifelse(PAQ_s$PAQ560 < 78, 7 * PAQ_s$PAQ560, 0)
  PAQ_s$PAD570 <- ifelse(PAQ_s$PAD570 < 6, PAQ_s$PAD570, 0)
  PAQ_s$PAQ580 <- ifelse(PAQ_s$PAQ580 < 6, 1.5 * PAQ_s$PAQ580, 0)
  PAQ$SCORE <- apply(PAQ_s[, -1], 1, function(x) sum(x))
}else if(year =="_B"){
  PAQ_s <- PAQ %>% select(SEQN, PAD020, PAQ100, PAQ180, PAD440, PAQ560, PAD590, PAD600)
  PAQ_s$PAD020 <- ifelse(PAQ_s$PAD020 == 1, 4, 0)
  PAQ_s$PAQ100 <- ifelse(PAQ_s$PAQ100 == 1, 4.5, 0)
  PAQ_s$PAQ180 <- ifelse(PAQ_s$PAQ180 == 1, 1.4, ifelse(PAQ_s$PAQ180 == 2, 1.5, ifelse(PAQ_s$PAQ180 == 3, 1.6, ifelse(PAQ_s$PAQ180 == 4, 1.8, 0))))
  PAQ_s$PAD440 <- ifelse(PAQ_s$PAD440 == 1, 4, 0)
  PAQ_s$PAQ560 <- ifelse(PAQ_s$PAQ560 < 78, 7 * PAQ_s$PAQ560, 0)
  PAQ_s$PAD590 <- ifelse(PAQ_s$PAD590 < 6, PAQ_s$PAD590, 0)
  PAQ_s$PAD600 <- ifelse(PAQ_s$PAD600 < 6, 1.5 * PAQ_s$PAD600, 0)
  PAQ$SCORE <- apply(PAQ_s[, -1], 1, function(x) sum(x))
}else if(year =="_C" || year =="_D"){
  PAQ_s <- PAQ %>% select(SEQN, PAD020, PAQ100, PAQ180, PAD440, PAQ560, PAD590, PAD600)
  PAQ_s$PAD020 <- ifelse(PAQ_s$PAD020 == 1, 4, 0)
  PAQ_s$PAQ100 <- ifelse(PAQ_s$PAQ100 == 1, 4.5, 0)
  PAQ_s$PAQ180 <- ifelse(PAQ_s$PAQ180 == 1, 1.4, ifelse(PAQ_s$PAQ180 == 2, 1.5, ifelse(PAQ_s$PAQ180 == 3, 1.6, ifelse(PAQ_s$PAQ180 == 4, 1.8, 0))))
  PAQ_s$PAD440 <- ifelse(PAQ_s$PAD440 == 1, 4, 0)
  PAQ_s$PAQ560 <- ifelse(PAQ_s$PAQ560 < 78, 7 * PAQ_s$PAQ560, 0)
  PAQ_s$PAD590 <- ifelse(PAQ_s$PAD590 < 6, PAQ_s$PAD590, 0)
  PAQ_s$PAD600 <- ifelse(PAQ_s$PAD600 < 6, 1.5 * PAQ_s$PAD600, 0)
  PAQ$SCORE <- apply(PAQ_s[, -1], 1, function(x) sum(x))
}else{
  PAQ_s <- PAQ %>% select(SEQN, PAD615, PAD630, PAD645, PAD660, PAD675)
  PAQ_s$PAD615 <- ifelse(PAQ_s$PAD615 < 841, 8 * PAQ_s$PAD615, 0)
  PAQ_s$PAD630 <- ifelse(PAQ_s$PAD630 < 841, 4 * PAQ_s$PAD630, 0)
  PAQ_s$PAD645 <- ifelse(PAQ_s$PAD645 < 661, 4 * PAQ_s$PAD645, 0)
  PAQ_s$PAD660 <- ifelse(PAQ_s$PAD660 < 481, 8 * PAQ_s$PAD660, 0)
  PAQ_s$PAD675 <- ifelse(PAQ_s$PAD675 < 541, 4 * PAQ_s$PAD675, 0)
  PAQ$SCORE <- apply(PAQ_s[, -1], 1, function(x) sum(x))
  PAQ$PAAQUEX <- NA
}
PAQ <- PAQ %>% select(SEQN, SCORE, PAAQUEX)
data <- join_all(list(data, PAQ), by = "SEQN", type = "left")

#睡眠问题
if(year != "" && year != "_B" && year != "_C"){
  SLQ <- read.xport(paste0(path, "SLQ",year,".XPT"))
  SLQ <- SLQ %>% select(SEQN, SLQ050)
  data <- join_all(list(data, SLQ), by = "SEQN", type = "left")
}else{
  data$SLQ050 <- NA
}


#心理健康
if (year =="" || year == "_B" || year == "_C"){
  #心理健康 - 抑郁症:抑郁评分
  if(year==""){
    CIQMDEP <- read.xport(paste0(path, "CIQMDEP",year,".XPT"))
  }else if (year == "_B" | year == "_C"){
    CIQMDEP <- read.xport(paste0(path, "CIQDEP",year,".XPT"))
  }
  CIQMDEP <- CIQMDEP %>% select(SEQN, CIDDSCOR)
  data <- join_all(list(data, CIQMDEP), by = "SEQN", type = "left")

  # #精神健康 - 广泛性焦虑症：焦虑评分
  # CIQGAD <- read.xport(paste0(path, "CIQGAD",year,".XPT"))
  # CIQGAD <- CIQGAD %>% select(SEQN, CIDGSCOR)
  # data <- join_all(list(data, CIQGAD), by = "SEQN", type = "left")

  # #心理健康 - 恐慌症：恐慌评分
  # if(year==""){
  #   CIQPANIC <- read.xport(paste0(path, "CIQPANIC",year,".XPT"))
  # }else{
  #   CIQPANIC <- read.xport(paste0(path, "CIQPAN",year,".XPT"))
  # }
  # CIQPANIC <- CIQPANIC %>% select(SEQN, CIDPSCOR)
  # data <- join_all(list(data, CIQPANIC), by = "SEQN", type = "left")
}else{
  DPQ <- read.xport(paste0(path, "DPQ",year,".XPT"))
  DPQ <- DPQ[, -which(names(DPQ) == "DPQ100")]
  DPQ <- na.omit(DPQ)
  DPQ$CIDDSCOR <- apply(DPQ[, -1], 1, function(x) sum(x[x < 7]))
  DPQ <- DPQ %>% select(SEQN, CIDDSCOR)
  data <- join_all(list(data, DPQ), by = "SEQN", type = "left")
}

#社会支持
if(year =="" || year == "_B" || year == "_C"){
  SSQ <- read.xport(paste0(path, "SSQ",year,".XPT"))
}else if(year =="_D" || year == "_E"){
  SSQ <- read.xport(paste0(path, "SSQ",year,".XPT"))
  SSQ <- SSQ[, !(names(SSQ) == "SSD044")]
}else{
  SSQ[c("SEQN", "SSQ011", "SSQ021A", "SSQ021B", "SSQ021C", "SSQ021D", "SSQ021E", "SSQ021F", "SSQ021G", "SSQ021H", "SSQ021I", "SSQ021J", "SSQ021K",
      "SSQ021L", "SSQ021M", "SSQ021N", "SSQ031", "SSQ041", "SSQ051", "SSQ061")] <- NA
}
names(SSQ) <- c("SEQN", "SSQ011", "SSQ021A", "SSQ021B", "SSQ021C", "SSQ021D", "SSQ021E", "SSQ021F", "SSQ021G", "SSQ021H", "SSQ021I", "SSQ021J", "SSQ021K",
      "SSQ021L", "SSQ021M", "SSQ021N", "SSQ031", "SSQ041", "SSQ051", "SSQ061")
data <- join_all(list(data, SSQ), by = "SEQN", type = "left")

#疾病诊断记录（有高血压、冠心病、心绞痛、心力衰竭、心脏病发作）
MCQ <- read.xport(paste0(path, "MCQ",year,".XPT"))
if(year =="" || year == "_B" || year == "_C" || year =="_D" || year == "_E" || year == "_F"){
  MCQ <- MCQ %>% select(SEQN, MCQ160B, MCQ180B, MCQ160C, MCQ180C, MCQ160D, MCQ180D, MCQ160E, MCQ180E)
}else if(year =="_G" || year == "_H" || year == "_I" ){
  MCQ <- MCQ %>% select(SEQN, MCQ160B, MCQ180B, MCQ160C, MCQ180C, MCQ160D, MCQ180D, MCQ160E, MCQ180E)
}else{
  MCQ <- MCQ %>% select(SEQN, MCQ160B, MCD180B, MCQ160C, MCD180C, MCQ160D, MCD180D, MCQ160E, MCD180E)
}
names(MCQ) <- c("SEQN", "MCQ160B", "MCD180B", "MCQ160C", "MCD180C", "MCQ160D", "MCD180D", "MCQ160E", "MCD180E")
data <- join_all(list(data, MCQ), by = "SEQN", type = "left")

#用药记录，天数、用量
#心内常用药
medicine = c("HYDROCHLOROTHIAZIDE", "VALSARTAN", "AMIODARONE", "AMLODIPINE", "ATORVASTATIN",
   "BENAZEPRIL", "OLMESARTAN", "PERINDOPRIL","TELMISARTAN","BENAZEPRIL","BENDROFLUMETHIAZIDE",
   "BEZAFIBRATE","BISOPROLOL","Captopril","Carvedilol", "EPINEPHRINE", "QUINIDINE", "Digoxin", 
   "Diltiazem", "Enalapril", "Eprosartan", "ERTUGLIFLOZIN", "SITAGLIPTIN", "EZETIMIBE", "SIMVASTATIN",
   "FENOFIBRIC ACID", "Furosemide", "GLICLAZIDE", "GLIPIZIDE", "METFORMIN", "HYDRALAZINE", "ISOSORBIDE DINITRATE",
   "IRBESARTAN", "METOPROLOL", "PROPRANOLOL", "ISOSORBIDE MONONITRATE", "NIFEDIPINE", "NITROGLYCERIN",
   "PITAVASTATIN", "PRAVASTATIN", "PRAZOSIN", "PROCAINAMIDE", "PROPAFENONE", "SACUBITRIL", "SOTALOL", "SPIRONOLACTONE",
   "TICAGRELOR", "TORSEMIDEMIDE", "VERAPAMIL", "TRIAMTERENE", "WARFARIN")
RXQ_RX <- read.xport(paste0(path, "RXQ_RX",year,".XPT"))
if(year == "" || year == "_B"){
  day_RXQ_RX <- RXQ_RX %>%
    select(SEQN, RXD240B, RXD260) %>%
    na.omit(.) %>%
    pivot_wider(names_from = RXD240B, values_from = RXD260,
    names_prefix = "day_",values_fill = 0, values_fn = list(RXD260 = sum))
  number_RXQ_RX <- RXQ_RX %>%
    select(SEQN, RXD240B, RXD295) %>%
    na.omit(.) %>%
    pivot_wider(names_from = RXD240B, values_from = RXD295,
    names_prefix = "number_",values_fill = 0, values_fn = list(RXD295 = sum))
}else{
  day_RXQ_RX <- RXQ_RX %>%
    select(SEQN, RXDDRUG, RXDDAYS) %>%
    na.omit(.) %>%
    pivot_wider(names_from = RXDDRUG, values_from = RXDDAYS,
    names_prefix = "day_",values_fill = 0, values_fn = list(RXDDAYS = sum))
  number_RXQ_RX <- RXQ_RX %>%
    select(SEQN, RXDDRUG, RXDCOUNT) %>%
    na.omit(.) %>%
    pivot_wider(names_from = RXDDRUG, values_from = RXDCOUNT,
    names_prefix = "number_",values_fill = 0, values_fn = list(RXDCOUNT = sum))
}
for (item in medicine){
  med_columns <- grep(item, names(day_RXQ_RX), value = TRUE)
  tmp = day_RXQ_RX[, c("SEQN", med_columns)]
  tmp[[paste0("day_", item)]] <- apply(tmp[, -1], 1, function(x) sum(x))
  tmp <- tmp %>% select(SEQN, paste0("day_", item))
  data <- join_all(list(data, tmp), by = "SEQN", type = "left")
  med_columns <- grep(item, names(number_RXQ_RX), value = TRUE)
  tmp = number_RXQ_RX[, c("SEQN", med_columns)]
  tmp[[paste0("num_", item)]] <- apply(tmp[, -1], 1, function(x) sum(x))
  tmp <- tmp %>% select(SEQN, paste0("num_", item))
  data <- join_all(list(data, tmp), by = "SEQN", type = "left")
}

#就诊情况
HUQ <- read.xport(paste0(path, "HUQ",year,".XPT"))
if(year == "" || year == "_B" ||year =="_E" || year =="_C" || year =="_D" || year =="_F"|| year =="_G"){
  if(year == ""){
    HUQ <- HUQ %>% select(SEQN, HUQ010, HUQ020, HUQ030, HUQ040, HUQ050, HUQ060, HUQ070, HUD080, HUQ090)
  }else if(year == "_B"){
    HUQ <- HUQ %>% select(SEQN, HUQ010, HUQ020, HUQ030, HUQ040, HUQ050, HUQ060, HUD070, HUQ080, HUQ090)
  }else{
    HUQ <- HUQ %>% select(SEQN, HUQ010, HUQ020, HUQ030, HUQ040, HUQ050, HUQ060, HUQ071, HUD080, HUQ090)
  }
}else{
  HUQ <- HUQ %>% select(SEQN, HUQ010, HUQ020, HUQ030, HUQ041, HUQ051, HUQ061, HUQ071, HUD080, HUQ090)
}
names(HUQ) <- c("SEQN", "HUQ010", "HUQ020", "HUQ030", "HUQ041", "HUQ051", "HUQ061", "HUQ071", "HUD080", "HUQ090")
data <- join_all(list(data, HUQ), by = "SEQN", type = "left")

#健康状况  胃病、肠病、HIV病毒、流感等  最近献血
HSQ <- read.xport(paste0(path, "HSQ",year,".XPT"))
if(year == ""){
  HSQ <- HSQ %>% select(SEQN, HSQ500, HSQ510, HSQ520, HSQ570, HSQ580, HSQ590, HSAQUEX)
}else if(year == "_B"){
  HSQ <- HSQ %>% select(SEQN, HSQ500, HSQ510, HSQ520, HSD570, HSQ580, HSQ590, HSAQUEX)
}else{
  HSQ <- HSQ %>% select(SEQN, HSQ500, HSQ510, HSQ520, HSQ571, HSQ580, HSQ590, HSAQUEX)
}
names(HSQ) <- c("SEQN", "HSQ500", "HSQ510", "HSQ520", "HSQ571", "HSQ580", "HSQ590", "HSAQUEX")
data <- join_all(list(data, HSQ), by = "SEQN", type = "left")

#身体机能
PFQ <- read.xport(paste0(path, "PFQ",year,".XPT"))
if(year == ""){
  PFQ <- PFQ %>% select(SEQN, PFQ020, PFQ030, PFQ040, PFQ048, PFQ050, PFQ055, PFQ056, 
          PFQ059, PFQ060A, PFQ060B, PFQ060C,PFQ060D,PFQ060E,PFQ060F,PFQ060G,PFQ060H,PFQ060I,PFQ060J,PFQ060K,
          PFQ060L,PFQ060M,PFQ060N,PFQ060O,PFQ060P,PFQ060Q,PFQ060R,PFQ060S, PFD067A, PFD067B,PFD067C,PFD067D,
          PFD067E, PFQ090)
}else if(year == "_B"){
  PFQ <- PFQ %>% select(SEQN, PFQ020, PFQ030, PFD040, PFQ048, PFQ050, PFQ055, PFQ056, 
          PFQ059, PFQ060A, PFQ060B, PFQ060C,PFQ060D,PFQ060E,PFQ060F,PFQ060G,PFQ060H,PFQ060I,PFQ060J,PFQ060K,
          PFQ060L,PFQ060M,PFQ060N,PFQ060O,PFQ060P,PFQ060Q,PFQ060R,PFQ060S, PFD067A, PFD067B,PFD067C,PFD067D,
          PFD067E, PFQ090)
}else{
  PFQ <- PFQ %>% select(SEQN, PFQ020, PFQ030, PFQ041, PFQ049, PFQ051, PFQ054, PFQ057,
          PFQ059, PFQ061A, PFQ061B,PFQ061C,PFQ061D,PFQ061E,PFQ061F,PFQ061G,PFQ061H,PFQ061I,PFQ061J,PFQ061K,
          PFQ061L,PFQ061M,PFQ061N,PFQ061O,PFQ061P,PFQ061Q, PFQ061R,PFQ061S, PFQ063A, PFQ063B,PFQ063C,PFQ063D,
          PFQ063E, PFQ090)
}
names(PFQ) <- c("SEQN", "PFQ020", "PFQ030", "PFQ041", "PFQ049", "PFQ051", "PFQ054", "PFQ057",
          "PFQ059", "PFQ061A", "PFQ061B","PFQ061C","PFQ061D","PFQ061E","PFQ061F","PFQ061G","PFQ061H","PFQ061I","PFQ061J","PFQ061K",
          "PFQ061L","PFQ061M","PFQ061N","PFQ061O","PFQ061P","PFQ061Q", "PFQ061R","PFQ061S", "PFQ063A", "PFQ063B","PFQ063C","PFQ063D",
          "PFQ063E", "PFQ090")
data <- join_all(list(data, PFQ), by = "SEQN", type = "left")

#认知功能
if(year=="" | year=="_B" | year=="_H" | year=="_G"){
  CFQ <- read.xport(paste0(path, "CFQ",year,".XPT"))
  if(year == "" || year == "_B"){
    CFQ <- CFQ %>% select(SEQN, CFDRIGHT)
  }else{
    CFQ <- CFQ %>% select(SEQN, CFDDS)
  }
  names(CFQ) <- c("SEQN", "CFDDS")
  data <- join_all(list(data, CFQ), by = "SEQN", type = "left")
}else{
  data$CFDDS <- NA
}

mortality_result = read.csv(file = paste0(path, "mortality_result.csv"))

data <- join_all(list(data, mortality_result), by = "SEQN", type = "left")

write.csv(data, file = paste0(path, "result", year, ".csv"), row.names = FALSE)

csv_files <- list.files(path = "NHANES", pattern = "\\.csv$", recursive = TRUE, full.names = TRUE)
df_combined <- NA
# 确保读取文件的路径是完整的
if (length(csv_files) > 0) {
  for (file in csv_files) {
    if (grepl("mortality", file)){
      next
    }
    # 读取每个.csv文件
    data <- read.csv(file, stringsAsFactors = FALSE)
    print(ncol(data))
    if (length(df_combined) == 0){
      df_combined <- data
    }else{
      df_combined <- rbind(data, df_combined)
    }
    # 这里可以添加代码进行数据处理
    print(paste("Read file:", file))
  }
}
write.csv(df_combined, file = paste0("NHANES/", "result_all", ".csv"), row.names = FALSE)
# data = read.csv(file = paste0(path, "result.csv"))

# head(data)

#加入污染物
library(ncdf4)
library(raster)

nc <- nc_open("CHAP_PM2.5_Y1K_2009_V4.nc")

data <- ncvar_get(nc, "PM2.5")
print(data)
lon <- ncvar_get(nc, "lon")
tori <- ncvar_get(nc, "time")

tunites <- ncatt_get(nc, "time", )


writeRaster(x = nc, filename = 'pre1.tif', format='GTiff', overwrite=TRUE)





# China_Health_and_Retirement_Longitudinal_Study_CHARLS
# demo_china <- read.dta("CHARLS/CHARLS2011_Dataset/demographic_background.dta")

# household_income_china <- read.dta("CHARLS/CHARLS2011_Dataset/household_income.dta")

# # UKDA
# demo_UK <- read.dta("UKDA-5050-stata/stata/stata13_se/wave_0_1998_data.dta")
