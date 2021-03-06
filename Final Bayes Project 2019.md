---
title: "Final Bayes Project 2019"
tags: Year 2.1 done
output: word_document
---

```{r}
library(papaja);library(knitr);library(mistr);library(readxl);library(tidyr);library(tidyverse);library(standardize);library(coda);library(lme4);library(MCMCvis);library(bayesplot);library(R2jags); library(R2OpenBUGS);library(plyr);library(pander); library(Matrix);library(lattice)
Data <- read_excel("Data.xlsx")
Data$Gums <- as.factor(Data$Gums)
Data$Gums_d_m <- as.factor(Data$Gums_d_m)
Data$Assessment_ease <- as.factor(Data$Assessment_ease)
Data$education <- as.factor(Data$education)
Data$Gender <- as.factor(Data$Gender)
Data$gender_care <- as.factor(Data$gender_care)
Data$training <- as.factor(Data$training)
perc<-table(Data$Facility_number,Data$training)[,1]/
(table(Data$Facility_number,Data$training)[,2]+table(Data$Facility_number,Data$training)[,1] )
perc<-round(perc,digits = 3)
length(which(plyr::count(Data,vars="training") == "video"))
length(which(plyr::count(Data,vars="training") == "standard" ))
num_train<-plyr::count(Data,vars="training")
num_train<-plyr::count(Data,vars="training")

colnames(Data)<-c("FAC","SUB","SEX","AGE","EASY","TRAIN","EDU","SEX_ND","GUM_ND","GUM_D")
Data$TP<-ifelse(Data$GUM_ND=="Healthy", 1, 0) #redefine the variable as true positive
Data$FP<-ifelse(Data$GUM_ND=="Not healthy", 0, 1) #redefine the variable as false negati

#Data
epa<-Data %>% group_by(SUB) %>% tally()
Data<-merge(Data,epa, by="SUB")


D <- Data
D$SEX<-relevel(D$SEX,ref="male");levels(D$SEX)
D[,3]<-as.numeric(as.factor(D[,3]))-1
D$EASY<-relevel(D$EASY,ref="Easy");levels(D$EASY)
D[,5]<-as.numeric(as.factor(D[,5]))-1
D[,6]<-as.numeric(as.factor(D[,6]))-1
D[,7]<-as.numeric(as.factor(D[,7]))-1
D$SEX_ND<-relevel(D$SEX_ND,ref="Male")
D[,8]<-as.numeric(as.factor(D[,8]))-1
D$GUM_D<-relevel(D$GUM_D,ref="Not healthy")
D$GUM_ND<-relevel(D$GUM_ND,ref="Not healthy")
D[,9]<-as.numeric(as.factor(D[,9]))-1
D[,10]<-as.numeric(as.factor(D[,10]))-1


D$AGE<-scale(D$AGE)
D$SEX<-scale(as.numeric(D$SEX))
D$SEX_ND<-scale(as.numeric(D$SEX_ND))
D$EASY<-scale(as.numeric(D$EASY))
D$TRAIN<-scale(as.numeric(D$TRAIN))
D$EDU<-scale(as.numeric(D$EDU))


Data1 <- subset(D, D$GUM_D == "1")  #Healthy==1
Data1<-Data1[,-12]  
Data2<-subset(D,D$GUM_D=="0")  #Not Healthy==0
Data2<-Data2[,-11]
DataH <- as.data.frame(sapply(Data1, as.numeric))
DataNH <- as.data.frame(sapply(Data2, as.numeric))
DataH$SUB1<-as.numeric(as.factor(DataH$SUB))
DataNH$SUB1<-as.numeric(as.factor(DataNH$SUB))

DataH$SUB_org<-DataH$SUB 
DataNH$SUB_org<-DataNH$SUB
DataH$SUB<-DataH$SUB1 
DataNH$SUB<-DataNH$SUB1
DataH<-DataH[-13]
DataNH<-DataNH[-13]

DataH <- as.data.frame(sapply(DataH, as.numeric))
DataNH <- as.data.frame(sapply(DataNH, as.numeric))

#for writing files
#write.csv(Data1,file="DentistData1.csv");
#Data <- as.data.frame(sapply(Data, as.numeric))
#colnames(Data)<-c("FAC","SUB","SEX","AGE","EASY","TRAIN","EDU","SEX_ND","GUM_ND","GUM_D", "TP", "FP", "n")
#write.csv(Data,file="DentistData.csv");
#write.csv(Data2,file="DentistData2.csv");

```





# 1.1 A Bayesian Hierarchical Model (BHGLMM)    

This is a study that assesses the performance of caregivers working in the care facilities in the Flanders region in Belgium. It is known that the performance of the caregivers, who received only a standard training, is relatively poor in assessing oral health status of the elderly residents.About 254 subjects were evaluated in one of the 9 Facilities (we assume nested subjects inside each Facility), by a dentist (always) and 4 non-dental caregivers (not always).
The aim of this analysis is check if the video training improve the performance of the scoring of the caregivers compared to the gold standard.      

The study is done in nine care facility where the patients were assess on gums by non-dental caregivers (two nurses and two nurse assistants) and by a dental (gold standard). The study can be consider as balance study with respect the effect to be study (496 gums evaluations were made it by ND who receive standard training, 489 evaluations for video training, balanced equally in each facility. But with respect of quantity of evaluations per subject is unbalanced,  the number measures done by ND on each subject: one measure: 1, two measures: 2, three measure: 14, four measures:237. 


### 1.1.1 EDA and Data transformation

Our response variable is asymmetric by nature (dentist are the gold-standard), so we can think in sensitivity and specificity measurements when the compassion is done. But why to fit a hierarchical model for a accuracy diagnosis study? Have been demonstrated previously that the agreement measurement  (percentage agreement, kappa, sensitivity and specificity) depends on the specific context of the study, because the clustered structure of data may have a strong impact on the estimate calculation [@agbajeMeasurementAnalysisInterpretation2012b]; such authors even reflect in the specific area of research, saying the agreement measurement "are influenced (in differing ways and extents) by the unit of analysis (mouth,tooth or surface level) and the disease level in the validation sample". 

The model will be fit for two subsets: first model where dentists assess (gold standard) as healthy the patient, and the second model where dentists assess the patient as non-healthy.

**Fit a hierarchical logistic regression** to model the probability that the caregiver (NDAsses=Healthy) also assesses as healthy (DAsses=Healthy); so the response variable  will be $\frac{P(NDAsses=Healthy)}{P(DAsses=Healthy)}$ with the logit link. 
First we need to understand how to nest the observations in each subject. A useful approach is the one used in meta-analysis of diagnostic accuracy  [@verdeBamditPackageBayesian2018a].
$tp_i \sim Binomial(TPR_i, n_{i,1})$, where $TPR_i =\frac{tp_i}{n{i,1}}$ 
$fp_i \sim Binomial(FPR_i, n_{i,2})$, where $FPR_i = \frac{fp_i} {n_{i,2}}$

| .      | With  disease | Without disease |
|--------|---------------|-----------------|
| Test + | $tp_i$        | $fp_i$          |
| Test - | $fn_i$        | $tn_i$          |
| Sum:   | $n_{i,1}$     | $n_{i,2}$       |

The scientific question is: Does the video training improve the performance of the scoring of the caregivers compared to the gold standard?. Rephrasing: Does the change in the percentage in true positive rate ($TPR_i$) or sensitivity of each caregiver evaluation is is a genuine effect or random fluctuation ? For the second part the response variable will be $FPR_i$
According to this question, the video training covariate needs to be consider as "fixed" effects. In Bayes approach all the parameters have a prior, so the concept of "Fixed" is used to follow the logical for interpretation in the classical approach. The rest of the variables will be consider "random" effects.

We assume that the data exhibit a three-level hierarchy, i.e. measurements ($Y_{ijk}$ or $GumsND_{ijk}$) are nested in the subject ($Sub_i$), which are nested in the care facilities ($FNumb_j$).

**Level 1 Observations**:$Y_{ijk} | \theta_{ijk}, \phi_{ijk}\sim exp[\frac{y_{ijk}\theta_{ijk}-b(\theta_{ijk})}{a(\phi_{ijk})}]+c(y_{ijk};\phi_{ijk})$. In this level the covariates ($X_{ijk}$) are: 1) random (u): education ($EDU*b_{}$), gender of caregiver ( $SEX_ND*b_{}$), easiness of evaluation ($EASY*b_{}$), 2) fixed: training ($TRAIN*\beta_{1}$)

**Level 2 Subject: $SUB_i$**: 
$logit(\mu_{ijk})= \boldsymbol{x}^T_{ijk}\boldsymbol{\beta}+z^T_{ijk}\boldsymbol{b_{ij}}$, with i.i.d. $\boldsymbol{b_{ij}}\sim N_q(\boldsymbol{0},G)$. The only covariates ($X_{ij}$) are random: gender ($SEX$) and age ($AGE$) of the resident (evaluated subjects).

**Level 3 $FAC_i$**: Facilities: $\boldsymbol{\beta}\sim(\boldsymbol{\beta})$ and 
$FNumb_j |$. There is no covariate ($X_{i}$) is this level, only random intercept for the facility ($b_{}$).

**Priors and hyperpriors**.  All the parameters are assume to follow the previous distributions: fixed and randoms. As priors we'll use  a vague prior $U(0,C)$ where C is a constant  which  are suggested priors in multilevel BGLMM models, and causally their its advise against the use of the  usual Jeffreys prior for BLMM which are not Jeffries priors for BGLMM [@lesaffreBayesianBiostatistics2012]. In specific, it will be assume a normal distribution for random effects for subjects and facility care ($u0_{fac} \sim N(\mu,\tau_{u0}$, and $b0_{sub} \sim N(\mu,\tau_{b0})$) with hierarchical centering approach (with a common mean $\mu \sim N(0,10^{-6})$), and no intercept for fixed effects.


### 1.1.2 & 1.1.3 BGLMM for Healthy gums

As follow we present classical results for Model 1 (Healthy group), modeling TP (True positiveness) made it by ND (SAS): From the table below, we can say that the standard training has more improvement than the video training with estimate of   exp(2.2848) = 9.8237.  

| Effect (Fixed Effect) | Estimate | SE     | DF  | t-Val | Pr>∣t∣Pr>∣t∣ |
|-----------------------|----------|--------|-----|-------|--------------|
| TRAIN Standard        | 2.2848   | 0.3063 | 336 | 7.46  | <.0001       |
| TRAIN Video           | 1.9145   | 0.2891 | 336 | 6.62  | <.0001       |
Table 1.1.2: Random Effects, Model Healthy


### 1.1.4 Check convergence using classical diagnostics

A Model BGLMM model was fitted in R2Openjags with  random intercept, following a normal distribution. A vague normal distribution, $\beta_{i} \sim$ N(0,10$^{-6}$) was used for prior fixed effects and uniform prior for the standard deviation of the random intersect i.e $\sigma_{u0}$, $\sigma_{b0}$ $\sim$ U(0,100). This model was fitted with three chains, 50000 iterations each and burn-in 0f 15000.The initial 50000 iterations were used as burn-in to discard the influence of the initial values on the sampling algorithm. Multiple chains was used to reveal the simple problem faster and to stop the chain to get stuck for a very long time in the area around a local mode. A variety of practical procedures have been suggested to check convergence via convergence diagnostics. The diagnostics involve two aspects: checking stationary of the chain and verifying the accuracy of the posterior summary measures [@lesaffreBayesianBiostatistics2012]. 

Firstly, trace plot and autocorrelation plot was used to show how fast the chain explores the posterior distribution, i.e to shows the mixing rate of the chain. 

Trace Plots are produced for each parameter separately and evaluate the chain uni-variately. In case of stationary, the trace plot appears as a horizontal strip and the individual moves hardly discernible. This is the basis of the informal thick pen test [@lesaffreBayesianBiostatistics2012]. The trace plots in the figure below pass this test, showing there is stationary of the chains.  

The mixing rate is measured by auto correlations of different lags. When future positions in the chain are highly predictable from the current position, then the posterior is slowly explored and one can says that the chain has a low mixing rate. The autocorrrelation plot is a useful tool but cannot be used as a convergence diagnostic [@lesaffreBayesianBiostatistics2012]. The autocorrelation plot in the figure below shows a good mixing for the coefficients (beta1, beta2) but a slow mixing for deviance and $\sigma$. 

Formal diagnostics test based on Brooks Gelman Rubin(BGR) was performed to confirm the graphical diagnosis. Gelman plots shows the Gelman Rubin statistics as the sampling iteration progress along three chains. The Gelman Rubin statistics measures the variability between and within chains, therefore, a value of 1 means there is no variation between chains. The chain convergences, if the black line should coverage into the horizontal line stationary at 1.  From the plots below, the $\hat{R}_c$ plot stabilizes faster for beta1, beat2, the deviance and the variance of the random effects, but for b0 has no yet stabilized after 46000 iterations. Further iterations appear necessary.              

 
**Tab. convergence plots for model with normally distributed parameters** 
![](4D2Ev4l.png)
**Trace Plot for $\beta$, $\sigma$, deviance**

![](JgD207H.png)
**Autocorrelation Plot for $\beta$, $\sigma$, deviance**

![](zQqF7My.png)
**BGR Plot for $\beta$, $\sigma$, deviance**





### 1.1.5 Perform posterior predictive checks to evaluate the proposed model.

 Posterior predictive check is way to look at the global measures of goodness of fit in comparing the observed data with their posterior predictive distribution which can be done through discrepancy measures and p-value. In this analysis, the posterior predictive checking of the response was performed using chi-square discrepancy measure to see how appropriate the proposed model is. The posterior predictive p-value was obtained from the chi-square discrepancy measure. The ppc for model fit comparisons between normal and diferent t-distributiosn wiol be done together in the next section.


### 1.1.6 Check also the normal distribution of the random effects. Verify if other distributions give a better model fit.

The posterior predictive check of the random effects were conducted using the following test statistics; minimum and maximum test,  Sinharay and Stern test, Skewness test and Kurtosis test in order to check the normality assumption. The mentioned tests above were also applied to assess the posterior predictive check of the random effects under the t distribution using three different degree of freedom (20,5,2). The degree of freedom was chosen as low as possible to have a really different distribution than normal distribution and also able to produce a convergence in the model. From the table below, it can be seen that the normal distribution and the t distribution has no different and for the tests the p-value suggest the random effects are normally distributed.   




| Test Statistics    | Normal σ∼U(0,100) | t-dist20  | t-dist5   | t-dist2   |
|--------------------|-------------------|-----------|-----------|-----------|
| tmin.test          | 0.4282933         | 0.4109867 | 0.3684533 | 0.3865333 |
| tmax.test          | 0.4946667         | 0.4911733 | 0.4859733 | 0.49736   |
| Sinharay and Stern | 0.4495733         | 0.43104   | 0.3948533 | 0.4231733 |
| Skewness           | 0.48176           | 0.47264   | 0.4394133 | 0.4383733 |
| Kurtosis           | 0.4841333         | 0.4870133 | 0.52144   | 0.5497067 |

Table 1.1.3 * Discrepancy measures for random effects comparing various distribution*

### 1.1.7 Check whether we can improve model fit by removing random effects for care facilities (level 3). 

In order to assess the goodness of fit of a model is via PPC, by sampling from the assume model and compare with the observed summary statistics via the use of the test statistics. The table below shows the posterior predictive p-value of 6 different test statistics under two different distribution; the normal distribution where $\sigma \sim$ U(0,100) and t-distribution of different degree of freedoms of the model with and with no random effect for care facilities. It can be seen that all these tests p-value suggest the models fit well. Also, it is observed that the tests p-value for model without random effect for care facilities is more likely to be near 0.5. This suggest that removing random effect for care facilities improves the model fitting.   


**Tab. Model Fit "Healthy Gum Model"(PPC)**

| Test Statistics    | Normal σ∼U(0,100) | t-dist20  | t-dist5   | t-dist2   | Normal NF σ∼U(0,100) | t-2 NF    |
|--------------------|-------------------|-----------|-----------|-----------|----------------------|-----------|
| tmin.test          | 0.4282933         | 0.4109867 | 0.3684533 | 0.3865333 | 0.4439467            | 0.4810667 |
| tmax.test          | 0.4946667         | 0.4911733 | 0.4859733 | 0.49736   | 0.4998933            | 0.5064    |
| Sinharay and Stern | 0.4495733         | 0.43104   | 0.3948533 | 0.4231733 | 0.46384              | 0.4928533 |
| Skewness           | 0.48176           | 0.47264   | 0.4394133 | 0.4383733 | 0.4799733            | 0.5068    |
| Kurtosis           | 0.4841333         | 0.4870133 | 0.52144   | 0.5497067 | 0.4817333            | 0.50848   |

Table 1.1.4 *Model(Without random effects for care facilities) fit with PPC *




Furthermore, model selection was performed between the two models with different priors for the Random effect (subject and facility). The table below, is the table for the evaluation of the models. We can see important difference between t dist of 2 dof and the normal distribution (differences of more than 10 might definitely rule out the model with the higher DIC, and differences between 5 and 10 are substantial). 


**Tab. Model Selection "Healthy Gum Model"**

| .   | Normal σ∼U(0,100) | t-dist20 | t-dist5 | t-dist2 | Normal NF σ∼U(0,100) | t-2 (No Fac) |
|-----|-------------------|----------|---------|---------|----------------------|--------------|
| DIC | 368.7             | 367.9    | 360.7   | 350.8   | 375.7                | 350.3        |
| pD  | 108               | 106.8    | 100     | 89      | 112.8                | 82.7         |

Table 1.1.5 *Comparing models with DIC and pD*


### 1.1.8 Give interpretation for the parameter(s) of interest

The table below shows the posterior summary measures of model without random effect for care facilities under normal distribution and t-distribution. It is observed that the model under t-distribution appears to affect the the posterior estimates of fixed effect and the variance parameter. Also, we can say that the estimated mean of the posterior distribution of the intersect parameter (beat1) in the model is 0.441 with posterior standard deviation of 99.921 and 95$\%$ credibility interval of [-196.101,195.953 ]. This is the expected value for logarithm of ...... when training is held constant. The relationship between training and the response is negative indicating that traings s the value of response decreases.  


| Estimates for Normal Distribution |  |  |  |  |  |
|------------------------------------|---------|--------------------|------------|----------|---------|
| parameter | mean | standard deviation | MCMC error | 2.5% | 97.5% |
| beta[1] | 0.153 | 99.921   | 5.3725e-01 | -194.479 | 195.967 |
| beta[2]: Training | -0.225 | 0.164 | 1.1671e-03 | -0.547 | 0.095 |
| sigma2_b0 | 3.108 | 1.414 | 3.2608e-02 | 1.118 | 6.527 |
| sigma2_u0 | 1.125 | 1.521 | 2.3377e-02 | 0.011 | 4.867 |
| deviance | 260.843 | 14.885 | 2.5141e-01 | 233.906 | 292.122 |
| Estimates for T_distribution(df=2) |  |  |  |  |  |
| beta[1] | 0.441 | 100.226 | 5.3725e-01 | -196.101 | 195.953 |
| beta[2] | -0.228 | 0.165 | 1.1671e-03 | -0.552 | -0.117 |
| sigma2_b0 | 0.792 | 0.499 | 3.2608e-02 | 0.183 | 2.067 |
| sigma2_u0 | 0.949 | 1.420 | 2.3377e-02 | 0.019 | 4.547 |
| deviance | 261.430 | 13.111 | 2.5141e-01 | 237.223 | 288.670 |


Table 1.1.6 *Coefficient Estimates of Proposed Models*


# 1.2 A Bayesian Hierarchical Model (BHGLMM)

#### 1.2.1 Repeat the previous task with the dataset where dentists assess as not healthy.

For all parameters, we considered similar vague priors that previous model, for the regression coefficients we take also similar vague priors that the previous model. 
As follow we present classical results for Model 2 (Non healthy group), modeling FP (False positive) made it by ND (SAS):

| Effect (Fixed Effect) | Estimate | SE | DF | t Value | Pr>∣t∣ |
|-----------------------|----------|---------|-----|---------|--------|
| AGE | 0.008755 | 0.01882 | 395 | 0.47 | 0.642 |
| SEX Female | 1.5463 | 1.7159 | 395 | 0.9 | 0.3681 |
| SEX Male | 0.8977 | 1.613 | 395 | 0.56 | 0.5781 |
| EASY Diff | 0.1534 | 0.3078 | 395 | 0.5 | 0.6186 |
| TRAIN Standard | 0.5151 | 0.2345 | 395 | 2.2 | 0.0286 |
| EDU No | 0.4109 | 0.3004 | 395 | 1.37 | 0.1721 |
| SEX_ND Female | -1.9879 | 0.4351 | 395 | -4.57 | <.0001 |

Table 2.1* Parameter Estimates (Non Healthy group) with classical  approach*

Consider only the observations where the dentists assess as not healthy. Using all available
covariates.

### 1.2.4 Check convergence using classical diagnostics

Taking vague prior, N(0,10$^{-6}$) for the regression coefficients and uniform prior for the standard deviation of the random intersect i.e $\sigma_{u0}$, $\sigma_{b0}$ $\sim$ U(0,100). Three chains were used to ft the model, 50000 iterations each and burn-in 0f 15000. The initial 50000 iterations were used as burn-in to discard the influence of the initial values on the sampling algorithm. Multiple chains was used to reveal the simple problem faster and to stop the chain to get stuck for a very long time in the area around a local mode. Trace plots were used to check convergence of the chains and autocorrelation of different lags measures the mixing rate of the chains. Brooks Gelman Rubin(BGR) diagnostic plot was done for formally check the convergence of the chains. From the trace below, it can be seen there is stationary of the chains. Also from BGR diagnostic plots all parameter estimate displayed are stabilized after 15000 iterations and 97.5$\%$ upper bound is 1, showing  convergence and good mixing rate of the Markov chains.     


![](cqBvSR8.png)
**Trace plot for $\beta$, $\sigma$, deviance****

![](dADT9lr.png)
**BGR Plot for $\beta$, $\sigma$, deviance**

### 1.2.5 PPC proposed model. PPC for other distributions.

The posterior predictive check of the random effects were conducted using the following test statistics; minimum and maximum test,  Sinharay and Stern test, Skewness test and Kurtosis test in order to check the normality assumption. The mentioned tests above were also applied to assess the posterior predictive check of the random effects under the t distribution using degree of freedom of 20. The degree of freedom was choosen as low as possible to have a really different distribution than normal distribution and also able to produce a convergency in the model. From the table below, it can be seen that the normal distribution and the t distribution has no different.

| Test Statistics         |P-value(t dist) (20) | P-value(Normal)     |
|-------------------------------------|-------------|------------|
| tmin.test                           |             | 0.98424    |
| tmax.test                           |             | 0.01461333 |
| Sinharay and Stern                             |             | 0.4886667  |
|Skewness  |             | 0.4189867  |
|Kurtosis |             | 0.01453333 |


### 1.1.6 Check also the normal distribution of the random effects. Verify if other distributions give a better model fit.


### 1.1.7 Check whether we can improve model fit by removing random effects for care facilities (level 3).


### 1.1.8 Give interpretation for the parameter(s) of interest

# Analysis2: A Bayesian Mixture Model


We need to model and investigate the annual number of doctor visits for elderly patients (65 and older) and the factors that may influence the frequency of visits. The data is a subset from the U.S. Medical Expenditure Panel Survey for 2003 with 1000 observations and 7 variables. The response is the annual number of doctor visits and the covariates are: whether the individual has private supplementary insurance, whether the individual has Medicaid, age in years, years of education, activity limitations, and the number of chronic conditions.


## 2.1 Given the count nature of the response, fit a Poisson regression model to the data. Check model fit, particularly for overdispersion.



$$log(\mu_{ij}) = \beta_0 + \beta_1private_{ij}+ \beta_2mediacaid_{ij} + \beta_3age_{ij}+ \beta_4education_{ij}+\beta_5actlim_{ij} + \beta_6chronic_{ij}$$

Where: $\mu_{ij}= E(Y_{ij})$ and Y$_{ij}$ is the annual number of doctor visits for the i_th patient in the j_th category of the covariates.

#### Parameter estimates Poisson Regression

| Effect | Parameters | Mean | Sd | MCMC error | 2.5% | 97.5% |
|-----------|------------|----------|--------|------------|----------|----------|
| Intersect | β0 | 0.791 | 0.142 | 2.9252e-03 | 0.510 | 1.074 |
| private | β1 | 0.102 | 0.026 | 5.8007e-04 | 0.051 | 0.152 |
| medicaid | β2 | 0.295 | 0.032 | 7.2570e-04 | 0.232 | 0.358 |
| age | β3 | 0.001 | 0.002 | 3.3187e-05 | -0.002 | 0.005 |
| education | β4 | 0.045 | 0.003 | 6.8837e-05 | 0.038 | 0.051 |
| actlim | β5 | 0.269 | 0.025 | 5.0084e-04 | 0.220 | 0.318 |
| chronic | β6 | 0.208 | 0.009 | 1.6677e-04 | 0.191 | 0.225 |
| deviance | Deviance | 8692.043 | 16.624 | 3.3559e+00 | 8661.928 | 8726.952 |

Table 2.1 Parameter Estimates for poisson regression

**PPC Modeling checking Poisson Regression** PPC is an approach to test goodness of fit  and also, is an approach that allows to sample from the assumed model and to compare the extremeness of the observed value via statistics to the sampled values under the assumed model [@lesaffreBayesianBiostatistics2012] . In this analysis, PPC compares the observed data with their posterior predictive distribution. The model fit to the observed data and the parameter values estimated at every iteration in the MCMC algorithm, is used to create replicates data set under the same model with the same parameter values thus an entire posteriour predictive distribution for each replicated data is created[@keryAppliedHierarchicalModeling2015].Bayesian p-value is commonly computed as the probability to obtain, under the nbull hypothesis of correctly specifed model, a test statistic that is at least as extreme as the observed test statistic computed from the actual data. 
From the table below ,fit.obs = chi square test statistic for actual dataset, fit.new = chi square test statistic for data sets simulated under our model using the posterior distribution, obs.range = range of actual dataset and new.range = range of simulated dataset.


| Effect | Mean | Sd | MCMC error | 2.5% | 97.5% |
|-----------|-----------|---------|------------|-----------|-----------|
| fit.new | 2707.141 | 133.715 | 2.3137e+00 | 2466.658 | 2966.483 |
| fit.obs | 19818.425 | 976.016 | 1.7123e+01 | 19664.692 | 19990.635 |
| new.range | 29.526 | 3.092 | 5.7313e-02 | 25.000 | 37.000 |
| obs.range | 144.000 | 0.000 | 0 | 144.000 | 144.000 |

**Table 2.2 *Discrepancy measures for PPC with Poisson Regression***
    
    
The degree lack of fit can be expressed as (fit.obs/fit.new) = 7.320 (overdispersion); this value indicates this model is improper, also a bayesian p-value of 0  supports an improper model fit. This difference is as a result of overdispersion present in the data. Aditional PPC test was run Var test1 = 1, Deviance test=0.999, and Deviance scaled test=1, whcih also reflect high ammount of overdisperssion. 



         
From the above, it can be seen that the estimate mean of the posterior distribution of the intercept paramater $\beta_{0}$ in the model is 0.791 with posterior standard deviation of 0.142 and a 95$\%$ credibility interval of [0.510, 1.065]. This is the expected value for logarithm of annual nuber of doctor visits for elderly patients when all the covariates are held constant. The relationship between $\beta_{1}$ and the annual nuber of doctor visits for elderly patients is positive indicating that as the $\beta_{1}$ increases so as the annual nuber of doctor visits for elderly patients  increases, the same is applied to other covariates.    

**Accuracy** According Raftery-Lewis diagnostics estimates the number of iterations required  are at least 3746 to estimate with an accuracy (tolerance) r of +/- 0.005  the 2.5% quantile of the posterior distribution and a probability of 0.95 of being within that tolerance.

#### Convergence diagnosis
Three chains were initiated with 20000 iterations and a burning of 10000 and thining= 10. The beta's were given normal priors(0,1.0E-06). Convergece for the MCMC was performed in order to check how close we are to the true posterior distribution. From the plots below, the trace plots for the regression coefficients appears as a horizontal strip and the individual moves are hardly dicernable. Also the autocorrelation plots confirm a good mixing for the regression coefficients and the deviance. The dynamic version of the Gelman Rubin(GR) AVONA diagnostic was performed. The $\hat{R}_c$ plot was stabilized for beta6, beta2, beta4, beta5 and the  deviance but the plot for beta0 and beta1 has not yet stabilized after the 20000 iterations and 0.975 quatile of $\hat{R}$ is fluctuating around 1.1 [@lesaffreBayesianBiostatistics2012].   

![](v1MfchA.jpg)
![](XTw09XC.png)
![](NzX4RsD.png)





## 2.2 Negative Binomial Model 

One way of dealing with overdispersion in Poisson regression is to use a negative binomial model. We can think of the negative binomial model as a continuous Poisson-gamma mixture. Fit a negative binomial model to the data using the mixture approach, and check for model fit.

In order to account for the overdispersion in the response a proposed negative binomial model(also known as poisson gamma mixture) is used. In the Negative binomial model, the log of the response is predicted as a linear combination of the predictors with the mixing distribution of the poisson rate being gamma distributed.The proposed model is given below;

$log(Y_{ij}) = \beta_0 + \beta_1private_{ij} + \beta_2mediacaid_{ij} + \beta_3age_{ij} + \beta_4education_{ij} +\beta_5actlim_{ij} + \beta_6chronic_{ij}$

where; $Y_i = NB(r,p)$ reperesents the mean number of doctor visits for the i_th patient in the j_th category of the covariates. An also $p_i = r/(r+ \lambda_i)$, $log(\lambda_i)= gamma(i)$, $gamma[i] = dnorm(mu[i],tau)$, where $\beta_0,...,\beta_6 = N(0,1.0e-06)$  and $tau = dgamma(0.1,0.1)$

#### Convergence diagnosis Negative Binomial
Three chains were initiated with 20000 iterations and a burning of 10000 and thining= 10. The beta's were given normal priors(0,1.0E-06). Convergece for the MCMC was performed in order to check how close we are to the true posterior distribution. From the plots below, the trace plots for the regression coefficients appears as a horizontal strip and the individual moves are hardly dicernable. Also the autocorrelation plots confirm a good mixing for the regression coefficients and the deviance. The dynamic version of the GR ANOVA diagnostic plot was applied to all the regression coefficients and the deviance. The plot of $\hat{R}_c$  sbtabilizes for beat1, beat2, beta5, beta6 and deviance, but the plot for beta0, beta3 and beta4 has not yet stabilized after 16000 iterations and the 0.975 quantile of $\hat{R}$ is fluctuating around 1.1.

![](bdfit3Q.png)
**Trace Plot for $\beta$, deviance**
![](2dXFRGA.png)
**Autocorrelation Plot for $\beta$,deviance**
![](OrZOHaC.png)
**BGR Plot for $\beta$,deviance**

#### Parameter Estimates Negative Binomial
The results below indicates a positive association between the average number of doctor visits for elder paitents with private, medicaid, age, education, actlim and chronic. 



| Effect | Parameter | Mean | Sd | MCMC error | 2.5% | 97.5% |
|-----------|-----------|----------|--------|------------|----------|----------|
| Intercept | β0 | -0.266 | 0.382 | 6.4939e-03 | -0.984 | 0.504 |
| private | β1 | 0.191 | 0.066 | 1.1629e-03 | 0.060 | 0.321 |
| medicaid | β2 | 0.091 | 0.089 | 1.5545e-03 | -0.080 | 0.266 |
| age | β3 | 0.011 | 0.005 | 7.8888e-05 | 0.002 | 0.021 |
| education | β4 | 0.027 | 0.009 | 1.8127e-04 | 0.010 | 0.043 |
| actlim | β5 | 0.203 | 0.072 | 1.3003e-03 | 0.060 | 0.343 |
| chronic | β6 | 0.280 | 0.024 | 4.7719e-04 | 0.234 | 0.327 |
| deviance | deviance | 4356.232 | 45.869 | 9.2314e-01 | 4266.551 | 4448.603 |
Table 2.3 Posterior Parameter Estimates For Negative Binomial

**Goodness of Fit Negative Binomial** From the table below a chi square test statistic for actual dataset for data sets simulated under our model using the posterior distribution, where test=fit.obs/fit.new, obs.range = range of actual dataset and new.range = range of simulated dataset. Bayes p values for $\chi^2 \quad \text{test}=0$. 

The degree lack of fit can be expressed as (fit.obs/fit.new) = 1.01. This value indicates both models are similar, further more a bayesian p-value of 0.41 (which is close to 0.5) supports a proper model fit.The difference between obs.range and new.range is small. The graphical representation also illustrates proper fit because points are scattered equally below and above the line.Therefore our model provides a good fit to our observed data and no evidence of overdispersion.


| Effects | Mean | Sd | MCMC error | 2.5% | 97.5% |
|-----------|----------|---------|------------|----------|----------|
| fit.new | 2423.924 | 124.255 | 2.4076e+00 | 2186.133 | 2673.560 |
| fit.obs | 2455.499 | 124.690 | 2.4751e+00 | 2220.625 | 2707.707 |
| new.range | 138.887 | 16.493 | 4.5925e-01 | 108.000 | 173.000 |
| obs.range | 144.000 | 0.000 | 0 | 144.000 | 144.000 |
![](itsBQKf.png)
Table 2.4 *PPC for Negative Binomial model*

## (PTV) I dont understand the difference between test!!!!!! PLEASE compare before and after:::
Aditional PPC test was run Variance test1 = 1, Deviance test=0.498666, and Deviance scaled test=1, which also reflect large ammount of overdisperssion; in particular we can se a reduction in Deviance test in NB (.49), compared with Poisson Reg Dev test (.99), which mean that NB captures somehow part of the overdispersion, but the rest of the test produces similar results suggest a overdispersion not explain with the current model.


# 2.3 Zero inflated Poisson (ZIP) mixture

ZIP can be viewed as a poisson-bernoulli mixture structure. This implies the observed counts are mapped into two outcomes; 1 for the inflated zeros and zero for all other observations consistent with the underlying poisson distribution. Our analyis comprises of two parameters where p=is the parameter indicating probability of our responses being an inflated zero and mu is the mean poisson parameter. The formal definition of a ZIP is present a continuation: If $y_i=0$ then  $p(y \mid \theta,mu)= \theta + (1-\theta)\times \text{Pois}(0|mu)$;  If $y_i>0$ then $p(y \mid \theta,mu) =(1-\theta)\times \text{Pois} (y_i \mid mu)$ where Expected value $E(Y)=\mu=mu\times(1-theta)$ and variance $var(Y)=mu\times(1-\theta)\times(1+\theta\times mu^2)$

#### Convergence diagnosis ZIP
The analysis for the Bayesian ZIP without covariates comprised of 20000 iterations with 3 chains and a burning of 10000. A uniform vague prior is assigned to the p parameter and a vague gamma prior is assinged to the mu. These measures ensured proper exploration and convergence of the MCMC chains. From the  trace plots below, the regression coefficients appears as a horizontal strip and the individual moves are hardly dicernable. Also the autocorrelation plots confirm a good mixing for the regression coefficients and the deviance. The plot of  $\hat{R}_c$  stabilizes for the deviance and mu, but the plot for p had not yet stabilized after 20000 iterations and the 0.975 quantile of $\hat{R}$ is fluctuating around 1.1.

![](StKUCyH.png)
**Trace Plot for p,mu,deviance**
![](l0z7TgY.png)
**BGR Plot for p,mu,deviance**
![](Bml56nf.png)
**Autocorrelatio Plot for p,mu,deviance**

#### Parameter Estimation ZIP
The posterior means and standard deviation of p and mu are reported in the table below. The table illustrates a mean of 7.86 for the poisson distributed observations and a probability of 0.902 indicating the probability of inflated zeros in the response. We check with a classical finite mixture approach (no covaritaes in SAS, with a ZIP mixture), getting exactly the same values for $\mu=7.8608$ and $P_i=0.9033$. 


| parameter | mean | sd | 2.5% | 50% | 97.5% | MCMC error |
|-----------|-----------|---------|-----------|-----------|-----------|------------|
| mu | 7.863 | 0.094 | 7.680 | 7.861 | 8.050 | 1.5229e-03 |
| p | 0.902 | 0.010 | 0.882 | 0.903 | 0.920 | 1.9326e-04 |
| fit.obs | 21715.008 | 131.013 | 21463.979 | 21713.803 | 21986.567 | 2.0869 |
| fit.new | 2536.209 | 124.499 | 2306.280 | 2532.619 | 2789.340 | 2.2560 |
| obs.range | 144.000 | 0.000 | 144.000 | 144.000 | 144.000 | 0 |
| new.range | 18.329 | 1.391 | 16.000 | 18.000 | 21.000 | 2.2512e-02 |
| deviance | 8233.780 | 9.438 | 8227.566 | 8228.602 | 8259.757 | 1.8798e-01 |

Table 2.5 ***Posterior Parameter Estimates For Zero Inflated Poisson Model*

### Goodnes of Fit ZIP

From the table above, the degree of lack of fit can be expressed as (fit.obs/fit.new) = 8.6. This value indicates the replicated data is far from similar with the observed data, further more a bayesian p-value of 0.00 supports an improper model fit. 

# 2.4 Finite mixture model and label switching (no covariates)

**Question**. Assuminge that each component is a different regression model. Fit a mixture of Poisson regressions to the data. To label solve the problem of label switching (labels are not consistent across the chains), we'll use constraints on the means. Priors will be compared: too flat priors may cause problems with mixture models, and initial values for the chains. Questions:What happens when you increase the number of components in the mixture? How many components do you think is appropriate for this data? Motivate your choice.

In Bayesian Finite mixture approach to estimate paratemer and clustering in mixture models, the label switching is a common problem produced  because the symmetry in the likelihood of the models parameters [@stephensDealingLabelSwitching2000b]. 
When label swithcing is not tackle, "there is a danger using this model that at some iteration all the data will go into one component of the mixture, and this state will be difficult to escape from"[@lunnBUGSBookPractical2012].For this issues two solutions has  proposed[@stephensDealingLabelSwitching2000b; @lunnBUGSBookPractical2012]: applying constaring to parameters and relabeling post-MCMC. The approach that we'll follow is order constraing into the group means [@lunnBUGSBookPractical2012]. Such approach is easily achieve trough a re-parameterisation where we assume $\lambda_2 = \lambda_1 + \theta$, where $\theta > 0$, which in bugs code could be: lambda[2] <- lambda[1] + theta, where theta and lambda can a unifrom distribution (for theta such distribution *must be* always positive to stablish the order between the lambdas). 
The model was written in R2Openbugs (becuase is the only software that aloow the use of Directhlet distribution for the probability to belong to a component), but the software present problems in the connection R to Openbugs, that was not present if the same code with the same data was run directly in OpenBugs, so we assume that probably is a real "bug". The finite mixture of Possions was made for two and three components; for the two components the initals was generated randomly from Openbugs, but for three components to avoid convergency issues we calculate in SAS a finite mixture, so we can be able to set  initials avlues close for the mean ($\lambda$) of each component ($\lambda_1=2.66,\lambda_2=11.12,\lambda_3=39.06$) in aclassical finite mixture model, and were used with sligth variations for the other initials, to improve convergency.

### Mixtures (2 and 3 components)  trace and convergency plots for $\lambda$ and p



## Mixture 2 and 3 components


A burn-in of 5000 iterations, the calculations of the following elements was done with 20000 iterations and a thin of 2, with 3 initials chains (generated randomly by Openbugs). A normal vague prior U(-100, 100) was taken for $\lambda_1$, and order lambda (to avoid labelling switching between lambda) with a thetha always positive $\theta_1, \theta_2 \sim U(0,1000)$, and finally the restriccion in the next lambda as follow: $\lambda_3=\lambda_2 + \theta_2, \quad \lambda_2 = \lambda_1 + \theta_1$

Using a hierarchical prior (i.e. a normal-gamma prior) for the class-specific means and variances, values for the Dirichlet hyperparameter α in the range 0.05–0.10 lead to acceptable results with both moderate or high separation between classes.

In the following models we use an alpha of 1 (parameters of the Direchlt dist for probability to belong to a component). 



![](8NATYYT.png)
**Fig. ?:**  Mixture (2 Poisson) trace and convergency plots for $\lambda$ and p


| Parameter | mean   | sd      | MC_error | val2.5pc | val97.5pc |
|-----------|--------|---------|----------|----------|-----------|
| p[1]      | 0.6786 | 0.02032 | 1.72E-04 | 0.6384   | 0.7179    |
| p[2]      | 0.3214 | 0.02032 | 1.72E-04 | 0.2821   | 0.3616    |
| lambda[1] | 3.445  | 0.1218  | 0.001183 | 3.208    | 3.685     |
| lambda[2] | 14.84  | 0.3603  | 0.003404 | 14.16    | 15.57     |
| fit       | 11070  | 137.7   | 1.239    | 10810    | 11350     |
| fit.new   | 2497   | 124     | 0.5202   | 2262     | 2748      |
| test[1]   | 0      | 0       | 4.08E-13 | 0        | 0         |
| test[4]   | 0.4972 | 0.5     | 0.001948 | 0        | 1         |
| test[5]   | 0      | 0       | 4.08E-13 | 0        | 0         |

TblsePosterior Parameter Estimates for Mixture (2 Poisson)
Posterior medians and 95% CI for the twop groups are 3.44 and 14.84, about 67% of the observations are clasiffied in the first component. In the table also are presented the same previous GOF test..**INTERPRETATION**

## Finite mixture of 3 components

A burn-in of 5000 iterations, the calculations of the following elements was done with 20000 iterations and a thin of 2, with 3 initials chains (generated randomly by Openbugs), with an assumtion that probility to belong to a component follow Direchlet(alpha=1) distribution. A similar order restricion as previous described, it was used for the lambda to avoid labelling switching.

![](Hn6j5a6.png)
**Fig. ?:**  Mixture (3 Poisson) trace and convergency plots for $\lambda$ and p



| Parameter | mean    | sd       | MC_error | val2.5pc | val97.5pc |
|-----------|---------|----------|----------|----------|-----------|
| p[1]      | 0.5578  | 0.02063  | 1.96E-04 | 0.5579   | 0.598     |
| p[2]      | 0.4162  | 0.02018  | 1.94E-04 | 0.4161   | 0.4562    |
| p[3]      | 0.02597 | 0.005427 | 4.05E-05 | 0.02562  | 0.03767   |
| lambda[1] | 2.671   | 0.1083   | 0.001144 | 2.67     | 2.885     |
| lambda[2] | 11.13   | 0.255    | 0.002499 | 11.13    | 11.64     |
| lambda[3] | 39.04   | 1.781    | 0.01461  | 39.02    | 42.55     |
| fit       | 5804    | 97.2     | 0.8443   | 5799     | 6009      |
| fit.new   | 2458    | 123.4    | 0.8308   | 2455     | 2710      |
| test[1]   | 0       | 0        | 7.07E-13 | 0        | 0         |
| test[4]   | 0.4903  | 0.4999   | 0.003565 | 0        | 1         |
| test[5]   | 0       | 0        | 7.07E-13 | 0        | 0         |



Posterior medians and 95% CI for the twop groups are 2.67, 11.13 and 39.04, about 55.7% of the observations are clasiffied in the first component and 41.6% second component. The low value in the third components is possible indication that the third component could not be so necessary.   In the table also are presented the same previous GOF test..




As a aditional comment for the Mixture of 2 (M2) and 3 components (M3), is that a sensityive analysis can be done to select the alpha value which produce an improvement in MCMC error of the parameters. In our model an Alpha equal to 0.1 didnt provide possibilities of fit the model, but with an alpha of 0.05, we saw an improvement of MCMC error for the lambda, but we can see that the estimates are similar with different asumptions in this two different priors selection (alpha=1 vs alpha=0.05).  Such result can be related to the recomendation to use a "Dirichlet hyperparameter $\alpha$ in the range 0.05–0.1" beacuse  lead to acceptable results with both moderate or high separation between classes".[@nasserinejadComparisonCriteriaChoosing2017c]. Such recomendation was found posterior to our first analysis. 

**Tab.** *Estimates for mxiture of 2 & 3 components. Improvement of MCMC error using an alpha=0.05 (compared with previous models with an alpha=1)*

| Mix 2     | mean   | sd      | MC_error | $\mid$ | Mix 3     | mean    | sd       | MC_error |
|-----------|--------|---------|----------|-------------|-----------|---------|----------|----------|
| lambda[1] | 3.455  | 0.1227  | 0.002367 | $\mid$ | lambda[1] | 2.672   | 0.1076   | 0.001745 |
| lambda[2] | 14.88  | 0.3685  | 0.006961 | $\mid$ | lambda[2] | 11.14   | 0.2531   | 0.004009 |
|           |        |         |          | $\mid$ | lambda[3] | 39.14   | 1.773    | 0.0239   |
| p[1]      | 0.6803 | 0.02051 | 3.38E-04 | $\mid$ | p[1]      | 0.5584  | 0.02066  | 2.93E-04 |
| p[2]      | 0.3197 | 0.02051 | 3.38E-04 | $\mid$ | p[2]      | 0.4166  | 0.02027  | 2.79E-04 |
|           |        |         |          | $\mid$ | p[3]      | 0.02495 | 0.005359 | 4.96E-05 |




**Model selection between two and three mixtures**. Instead DIC is a popular well-established criterion for comparing different Bayesian models, unfortunately this criterion is not suited to the case of mixture models [@nasserinejadComparisonCriteriaChoosing2017c]. In the context of Bayesian Mixtures, several criteria have been proposed, such as adaptations of the deviance information criterion, marginal likelihoods, Bayes factors, and reversible jump MCMC techniques [@nasserinejadComparisonCriteriaChoosing2017c]. For model selection between Mixture of two or three components,  we'll use Bayes factor. 
For the sake of illustration of the comparisson process we run an extra Poisson with 4 components (M4) (with similar priors), so calculations for PPO, CPO was made with OpenBugs, Excell and finally R, where $\sum_ilog( \widehat{CPO}(M2))=-2.823115$, $\sum_ilog( \widehat{CPO}(M3))=-2.500475$, and $\sum_ilog( \widehat{CPO}(M4))=-2.483234$. So the Pseudo Bayes Factor (PSBF) is equal to $\widehat{PSBF_{32}}=1.381$ 
$\widehat{PSBF_{43}}= 1.01739$, and $\widehat{PSBF_{42}}=1.40478$. We can conlclue that the preferable model is model with 4 components beacuse produce the lower $\sum_ilog( \widehat{CPO})$.

 
## 2.5 Finite Mixture with covariates

In Tasks 3 and 4, we assumed that the mixing probabilities are fixed across the observations and independent of the covariates. However, in practice this is a very restrictive assumption. We can instead let the mixing probabilities vary across individuals and depend on the covariates. Refit the zero inflated model of Task 3 and the mixture model from Task 4 while modelling the mixing probabilities using the covariates. Which covariates do you think are important and influence the mixing probabilities?. Use posterior predictive checks and other measures to choose an appropriate model among all the models you fitted. Can you use the model to identify clusters in the data, and important characteristics of the clusters?

The model was fitted according to the equations:
Assuming the follwing distributions $W \sim Ber(\pi)$, $Y \sim Poi(\mu W)$, and for the likelihood : $log(\mu)=\beta_1 +\beta_2X$, $logit(\pi)=\gamma_1+\gamma_2$. The code was adaptted from a public code at [@hilbeBayesianModelsAstrophysical2017]. A model was fit with three chains = 3, a burnin of 10000 with 50000 iterations, and a thin of 3. Initials values was requiere to produce from beta = rnorm(Kc, 0, 0.1) and gamma = rnorm(Kb, 0, 0.1), where Kc=Kb=design matrix.  The Fitted model had a pD = 48.1 and DIC = 8319.1. Deviance: 7584.302.

![](YzOvThL.png)
**Trace Plot for $\beta$, $\gamma$**

![](prUzW67.png)
**BGR Plot for $\beta$, $\gamma$**

![](ZDrhKqQ.png)
**Autocorrelation Plot for $\beta$, $\gamma$**

| Par for $\mu$   | Est [SE]     | Par for $P_i$   | Est [SE]          |
|--------------|--------------|--------------|-------------------|
| Private:$\mu$| 0.51*        | Private:$P_i$   | -1.09             |
|              | [0.15; 1.01] |              | [-178.06; 171.95] |
| medicaid:$\mu$  | 0.12*        | medicaid:$P_i$  | -1.16             |
|              | [0.06; 0.19] |              | [-181.07; 173.15] |
| Age:$\mu$       | 0.16*        | Age:$P_i$       | -0.05             |
|              | [0.09; 0.24] |              | [-175.63; 173.89] |
| Education:$\mu$ | 0.01*        | Education:$P_i$ | -58.07            |
|              | [0.00; 0.01] |              | [-213.53; 0.01]   |
| actlim:$\mu$    | 0.03*        | actlim:$P_i$    | -9.04             |
|              | [0.03; 0.04] |              | [-182.55; 154.17] |
| chronic:$\mu$   | 0.20*        | chronic:$P_i$   | 0.5               |
|              | [0.14; 0.26] |              | [-173.38; 178.97] |




**Limitations**: The use of posterior predictive distributions is a very general way of assessing the fit of a model when using MCMC model fitting techniques
[@gelmanBayesianDataAnalysis2013]
Some statisticians don’t like posterior predictive checks because they
use the data twice: first, to generate the replicate data and second to
compare them with these replicates [@keryIntroductionWinBUGSEcologists2010]. Other approachs are cover by Ntzoufras [@ntzoufrasBayesianModelingUsing2009].






# To add

Similar coefficients calculation for Training was found in the three explored models, which means that training (ref=1 for training with video) reduce the number of disagrement (FP) in the non-healthy population  around -0.32 in the logit coefficient scale. 

| .         | est[se]: N$\sigma \sim U(0,100)$ | est[se]: t-dist2 | est[se]: N$\sigma \sim U(0,100)$. NF |
|-----------|----------------------------------|------------------|--------------------------------------|
| Training     | -0.322[0.132]                    | -0.326[0.132]    | -0.327[0.13]                         |
| Sex Pat.    | 0.359[0.182]                     | 0.384[0.17]      | 0.436[0.185]                         |
| Age    | 0.077[0.18]                      | 0.051[0.174]     | 0.101[0.179]                         |
| Easyness    | 0.106[0.204]                     | 0.083[0.204]     | 0.166[0.189]                         |
| Education    | -0.221[0.152]                    | -0.217[0.152]    | -0.25[0.138]                         |
| Sex ND    | -0.913[0.185]                    | -0.923[0.188]    | -0.906[0.184]                        |
| sigma2_b0 | 2.181[0.767]                     | 1.753[0.583]     | 2.434[0.822]                         |
| sigma2_u0 | 1.042[1.152]                     | 1.079[1.179]     |                                      |
| PPC1      | 0.3825867                        | 0.32888          | 0.49128                              |
| PPC2      | 0.48824                          | 0.4828           | 0.5017067                            |
| PPC5      | 0.40656                          | 0.3673067        | 0.4977333                            |
| PPC6      | 0.4499467                        | 0.4010933        | 0.4981867                            |
| PPC7      | 0.49248                          | 0.53632          | 0.4933333                            |
| DIC       | 620.7                            | 620.9            | 635.9                                |
| pD        | 151.6                            | 153.5            | 162.3                                |
*Tab. Bayesian Hierarchical Models for Nonhealthy gums *




Interpretation of the effect of Training with video (ref=1 for covariate beta2) means 
healthy=1

In healthy ppulation,  the video interventation (without controling with covariates) reduce the agrement in in diagnosis


| Estimates for Normal Distribution |  |  |  |  |  |
|------------------------------------|---------|--------------------|------------|----------|---------|
| parameter | mean | standard deviation | MCMC error | 2.5% | 97.5% |
| beta[1] | 0.153 | 99.921   | 5.3725e-01 | -194.479 | 195.967 |
| beta[2]: Training | -0.225 | 0.164 | 1.1671e-03 | -0.547 | 0.095 |
| sigma2_b0 | 3.108 | 1.414 | 3.2608e-02 | 1.118 | 6.527 |
| sigma2_u0 | 1.125 | 1.521 | 2.3377e-02 | 0.011 | 4.867 |
| deviance | 260.843 | 14.885 | 2.5141e-01 | 233.906 | 292.122 |
| Estimates for T_distribution(df=2) |  |  |  |  |  |
| beta[1] | 0.441 | 100.226 | 5.3725e-01 | -196.101 | 195.953 |
| beta[2] | -0.228 | 0.165 | 1.1671e-03 | -0.552 | -0.117 |
| sigma2_b0 | 0.792 | 0.499 | 3.2608e-02 | 0.183 | 2.067 |
| sigma2_u0 | 0.949 | 1.420 | 2.3377e-02 | 0.019 | 4.547 |
| deviance | 261.430 | 13.111 | 2.5141e-01 | 237.223 | 288.670 |

