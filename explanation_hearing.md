# Evolution of Hearing Thresholds and effect of Age

## Introduction
Over 5% of the worlds population have a hearing loss disability, 34 millions of them are children. It is estimated that by 2050 one in every ten people will have disabling hearing loss. Possible causes which may lead to hearing loss include but not limited to: occupational noise exposure, heredity, complications at birth, chronic ear infections and ageing [9]. Although many adults retain good hearing as they grow old, hearing loss related to age  can vary in severity from mild to substantial is common among elderly people [4]. Overall, 10% of the population has a hearing loss great enough to impair communication, and this rate increases to 40% in the population older than 65 years. About 80% of hearing loss cases occur in elderly people [2]. This study addresses different methods of analyzing unbalanced longitudinal data, with repeated measurements (in this case of hearing thresholds  dB), taken at a frequency of 1000 Hz, averaged over both ears (left and right). Therefore the evolution of hearing thresholds over time and the relationship with age.

## Data and Variables
The data considered in this study are longitudinal measurements of hearing thresholds (in dB), measured at a frequency of 500 Hz, of 1000 Hz, for the averaged over both ears (left and right). The Measurements were taken in a sound-proof chamber, by means of a Bekesy audiometer. Patients had varying repeated measurements that were unequally spaced, with some having only one measurement (101 patients) and others having as many as 14 repeated measurements. In total, there were 543 patients whose age at entry in the study ranged from 18.1 and 95.8 years (with a median age at the first visit of 52.1 years). Also, the follow-up time ranged from 0 to 22.8 years (a median follow-up time of 4.5 years), producing 2155 observations. The outcome of interest was the hearing threshold with age and time as the covariates.

## Methodology
### Exploratory Data Analysis
Graphical techniques were used in to discover patterns of systematic variation that distinguish individual patients and also to aid in model building. Techniques such as individual profiles, mean structure, the variance structures, and correlation structures were explored to see how the evolution of the hearing threshold depends on time.

### Summary statistics methods
Due to the longitudinal nature of the data analyzed, the data is correlated within subject. To handle this dependence structure and in order to investigate the effect of age on hearing thresholds of individual subjects, the number of measurements of each subject can be reduced by applying summary statistics methods. However, the choice of measurement depends on the question of interest and the nature of the data. Since the dataset is highly unbalanced, the appropriate summary statistics techniques used were:
 * Analysis of Increments, which applied to compare evolution between subjects, correcting for differences at baseline of hearing threshold and using age as a covariate.
 * Analysis of Area Under the Curve (AUC), which calculates the area under the curve between consecutive time of measurement (hearing threshold), adjusted by age.
 * Analysis of covariance (Regression), used to analyze the last measurement by correcting the baseline value and using age as a covariate.

The advantages of these three methods are that they do not assume balanced data and that there are no problems with multiple testing. However, all these methods result in loss of information which implies caution in interpretation. In addition, they often do not allow to draw conclusions about the way the endpoint has been reached [8].

### Multivariate Model
To study the evolution of hearing threshold over time and how it depends on age, a multivariate regression model was fitted. To find the most parsimonious model with a mean structure that best describes the average evolution of the hearing threshold, a likelihood ratio test was conducted.
Let $Y_{i}$ be a vector of repeated measurements of hearing threshold for $i^{th}$ subject, such that $Y_{i}$ = $(Y_{i1},Y_{i2},..., Y_{ini})^{T}$ . The general multivariate model assumed, is defined as follows:

$$Y_{i} = X_{i}\beta + \epsilon_{i}$$

Where $X_i$ is the matrix of covariates age and time since entry in the study, $\beta$ is the vector of regression parameters and $\epsilon_{i}$ is the vector of error components with $\epsilon_{i} \sim N(0,\sum)$. The mean structure of the first model was chosen based on the exploratory data analysis and then it was compared with the submodels using the likelihood ratio test and also select the best model using AIC. The current data set is highly unbalanced, which implies that compound symmetric covariances are meaningful, but based on the strong assumption of constant variance and covariance. Other covariance structures like Toeplitz and Auto-Regressive are not meaningful in this case (unequally spaced time points). In addition, due to the unbalanced nature of the data, the unstructured mean structure was not considered. Therefore, Age and time were treated as continuous covariates in fitting the mean structure, and the most parsimonious and best fitting model is retained.

### Two-stage Analysis
A two-stage analysis technique is one possible way to summarise the measurements from an individual as well as analyses of the summary statistics through classical regression techniques while accounting for the within and between variability. It is considered since the data is highly unbalanced and multivariate regression techniques often are not applicable. Due to the multivariate models, the interpretation of the estimates is on average and not subject-specific [8]. In the first stage of the two-stage analysis, a linear regression model for each subject separately is fitted to describe the observed variability within the subjects. Afterward, variability in the subject-specific regression coefficients is explained using the age of each subject in the second stage.

**Stage 1:** Assume the response that $Y_{i}$ satisfies the linear regression model which means hearing thresholds are modeled against the time covariates.
    
$$Y_{i} = X_{i}\beta + \epsilon_{i}$$
    
Where $Y_{i}$ for $i = 1,2,3,...,543$ is the hearing threshold (response) vector for the $i_{th}$ subject. $Z_{i}$ is the matrix which contains the known time covariates and $\beta_{i}$ is the vector containing the subject-specific regression coefficients. The variability within each patient is represented by $\epsilon_{i}$. Usually $\epsilon_{i}$ assumed to $\epsilon_{i} \sim N(0,\sigma^{2}I_{ni})$ where $I_{ni}$ is the $n_{i}$-dimensional identity matrix[8]. The size of this structure depends on the number of measurements of each person. In order to investigate whether other terms such as linear or quadratic are important, an overall test an overall test $(F_{meta})$ for the need to extend the stage 1 model is conducted [8]. In addition, the overall coefficient $R_{meta}^{2}$ of multiple determination is calculated to explore the total within-subject variability explained by the model under consideration.

**Stage 2:** In this stage, multivariate regression model was used to explain the observed variability between the patients.

$$K_{i}\beta + b_{i}$$

Where $K_{i}$ is the matrix of known covariates basline age and $\beta$ is the vector  regression parameters. The error terms are denoted by $b_i$ represent the variability between the patients. It describes how much the profile of patient $i^{th}$ differs from the average profile. It assumed that $b_{i} \sim N(0; D)$ are independent [8].
It can be observed from the above models that, the Two-Stage analysis is performed explicitly making it appear like the summary statistics. While this approach carries the advantages associated with the summary statistics described in subsection Summary Statistics. It also carries with it similar drawbacks. First, in this approach we are no longer modelling the variable of interest directly, hence, information is lost by summarizing the observed data, and secondly, by replacing the true regression coefficient value by their estimates, we are introducing random variability into our analysis. [8].

### Random Effects
The two-stage analysis does not take proper account of the different precision among subjects in estimating their intercepts and slopes. The reason is the number and timing of measurements vary among subjects. This associated drawbacks in a two-stage approach can be avoided by combining the two-stages into one model without losing much information by taking into account the correlations among the measurements. This model is the Linear Mixed-Effects Model [8]. Linear mixed models provide a way to model correlations among measurements within a subject using random effects and through the additional specification of a covariance structure. The model is defined as:

$$Y_{ij} = X_{i}\beta + Z_{i}b_{i} + \epsilon_{ij}$$

Where, 

$$b{_i} \sim N(0,D)$$
$$ \epsilon_{ij} \sim N(0,\sum_{i})$$

$Y_{i}$ is the $n_{i}$-dimensional hearing threshold (response) vector for the patient $i^{th}$. $X_i$ and $Z_i$ are the design matrices for the fixed and random effects of known covariates respectively. $\epsilon_{ij}$ is the vector containing the residual
components, and $\epsilon_{ij}$ and $b_i$ are independent for $i = 1,2,..., 543$ [8]. This model has the advantage that, in addition to allowing us to study the mean evolution of individual patients observed over some period of time, it also helps to evaluate the individual deviations from this mean profile [7]. A mixture of chi squares distribution was used to test for the need of random effects in the model.

## Results and Discussion
### Exploratory Data Analysis

The number of measurements varied from 1 to 14 among 543 patients, with patients having lower numbers being more frequent as number of follow up increases. For instance, in Table [1], not all patients had measurements up to 14. Only one patient had14 measurements and 0.4% of the patients had 13 while about 39% were observed at most 2 times and 49% of the patients have between 3 to 7 measurements. The rest of subjects (about 12%) were measured only 8 to 13 times. This means that the number of patients who were followed up for a long period was small compared to those who followed up only once or twice.This can be considered as evidence of the highly unbalanced data.

**Table 1: Follow-up Summary**
| # of Follow Up | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| Frequency | 101 | 109 | 90 | 53 | 45 | 46 | 32 | 23 | 21 | 9 | 6 | 5 | 2 | 1 |
| Percent(%) | 18.6 | 20.1 | 16.6 | 9.8 | 8.3 | 8.5 | 5.9 | 4.2 | 3.9 | 1.7 | 1.1 | 0.9 | 0.4 | 0.2 |

### Individual Profile Plots
In total, there were 543 subjects with hearing scores at different time points. The measurements are unbalanced since the timepoints are not commonly fixed for all subjects. Additionly, there is unequal space between time points. The average of hearing threshold varied from 0 dB to 74.5 dB. The age of the subjects at entry in the study ranges from 18.1 to 95.8 years. At the start of the study (Time = 0) the mean and standard deviation of hearing threshold was about 6.76 dB and 8.99 dB respectively. 
The individual profiles of 100 randomly selected patients are displayed in Figure [1]. From these profiles, it is observed that there is a high variability between-subject and within-subject. Due to the large difference at baseline in the hearing threshold, there are different intercepts for subjects. Nonetheless, age also can impute to those differences in hearing thresholds at the beginning of the study. Moreover, the evolution of the hearing threshold over time looks to be different for the subjects, which might suggest an individual time effect for each subject. Besides, evolution can also depend on age. On the whole, the individual profiles support a random-effects model.


![](https://i.imgur.com/bLuVaZS.png)
**Figure 1: Individual profiles of 100 randomly selected subjects**


### Mean Structure:
For the mean structure, since the data are unbalanced, smoothing techniques were used to estimate the average evolution over time. The figure 2 below showing the smoothed overall average trend in threshold frequencies does not suggest a linear trend (curvature along the time axis). However to get a better view, three age groups (15 < age ≤ 40, 40 < age ≤ 65, and age > 65 years) were created and average trend were made by age category. Thus the mean structure is investigated by age group. In all age groups, the average evolution suggests a linear line in the hearing threshold over time with the increase and curvature are even higher in the youngest group. Given these findings, there might be a dependence of hearing threshold evolution over time on age. Therefore, a model with time and age effects with interaction may be a good starting point to model the mean structure. However, this has to be tested formally.

![](https://i.imgur.com/ItzOAVg.png)
**Figure 2: Smothed average hearing threshold for all patients,agegroup1,agegroup2 and agegroup3 over time**


### Variance Structure 
The smoothed variance function in Figure 3 was slightly increasing and decreasing, incorporation of both random effects would be plausible to account for both within- and between-variability. This has to be tested formally when formulating the random-effects model.

![](https://i.imgur.com/DIBBTsR.png)
**Figure 3: The smoothed variance function**


### Correlation Structure
A correlation structure was explored using semi-variogram as shown in Figure 4. This plot depicts three information. Firstly, the total variability is as indicated by a horizontal line (=75.225) and it was almost equally shared by the random intercept variability and measurement error. Secondly, the bold black line was nearly horizontal that statistically translates to the absence of serial correlation. Finally, the correlation of measurements within a subject seem to be accounted for random intercept and measurement error only.

![](https://i.imgur.com/WU9BElw.png)
**Figure 3: The semi-variogram of hearing threshold**

## Summary Statistics
The initial analysis was done by fitting different summary statistics to check whether they lead to the same results. Three summary statistics were found appropriate namely; analysis of area under the curve, analysis of increments, and analyses of covariance were applied since the given dataset is unbalanced. The results of the analysis of the summary statistics, presented in Table [2], it is clear that there is a significant effect of age in the hearing threshold with a positive slope in all used methods. This leads to the conclusion that in all three analyses, we observed that older subjects tend to have higher hearing thresholds. However, these approaches have the disadvantage that when summarize the data using these approaches, we often lose a lot of information because they only use partial information and the correlation between measurements was not taken into account. Besides these methods do not elucidate subjects’ evolution over time. The baseline hearing threshold $(Y_0)$ was highly significant in the Analysis of Covariance. This implied that the baseline hearing threshold differed significantly among subjects and also has a significant effect on the final hearing threshold. The results from these methods should be interpreted with caution since they are saddled with limitations.

**Table 2: Summary statistics**
|           | Analysis of Increment |       |         | AUC     |       |         | Analysis of Covariance |       |         |
|:---------:|:---------------------:| ----- | ------- | ------- | ----- |:-------:|:----------------------:| ----- | ------- |
| Variables |         Est.          | S.E.  | p-value | Est.    | S.E.  | p-value |          Est.          | S.E.  | p-value |
| Intercept |        -5.006         | 0.919 | <.0001  | -31.381 | 7.802 | <.0001  |         -6.094         | 0.909 | <.0001  |
|    Age    |         0.115         | 0.015 | <.0001  | 2.226   | 0.133 | <.0001  |         0.157          | 0.016 | <.0001  |
| Baseline  |                       |       |         |         |       |         |         0.804          | 0.033 | <.0001  |

## Multivariate Model
In order to apply different covariance structures, we preliminarily discretized the time variable in a 1 year interval. Initially, there were 207 distinct time points and after discretization it reduced to 24 time points $(0,1,..., 23)$. This reduced of the dimension of the covariance structure of repeated measurements from 207 × 207 to 24 × 24.
The mean structure plot from Figure 2 above showed that the evolution over time of hearing threshold seemed to be different according to age groups and showed a curvature for some of these age group. As a result, a linear mean on the covariates time and age is used. Additionally, as variance structure was constant, the primary proposition of the covariance structure for the repeated observations was Compound Symmetry. Structures like unstructured, simple, and compound symmetry, was checked because of the unequally spaced in the time variable. Nevertheless, Compound Symmetry, which implies constant correlation within a subject, is the most plausible and parsimonious covariance structure. While simple covariance structure ignores the correlation within a subject and the unstructured covariance assumption was also failed because the data set was smaller in contrast to the number of distinct time points of hearing threshold measurements, both were clearly unrealistic for measurements of hearing threshold.
Table [3] shows the likelihood ratio (LR) test for the comparison of mean structure that is more parsimonious. The full model considered contains the covariates age, time and interaction term between age and time with both age and time treated as continuous variables. Other reduced models were compared with the full model by conducting the likelihood ratio test. Based on the test, model (1) including the covariates age, time, and interaction term between age and time, was found to be the most parsimonious model as:

$$Y_{ij} = \beta_{0} + \beta_{1}Age_{i} +\beta_{2}Time_{ij} + \beta_{3}(Age_{i} * Time_{ij}) + \epsilon_{ij}$$

where, $Y_{ij}$ is the hearing threshold of the patirnt $i$ at time point $j$. Age, is the age of the patient $i$ at time $j$. Time, is number of years from the first entry for the patient $i$. Finally, $\epsilon_{ij}$ is a random error terms with
the assumption $\epsilon_{ij} \sim N(0; Σ)$.


**Table 3: Summary**
| # | MeanStr. | Cov.Str. | Par  | -2l | AIC | Ref | G2 | DF | p-value |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 1 | Int. + Time + Age + Time × Age | CS | 6 | 13507 | 13519 |  |  |  |  |
| 2 | Int. + Time + Age | CS | 5 | 13646.7 | 13656.7 | 1  | 139.7 | 1 | <0:0001 |
| 3 | Int. + Age+ Time × Age | CS | 5 | 13630.4 | 13640.4 | 1 | 123.4 | 1 | <0:0001 |
| 4 | Int. + Time + Time × Age | CS | 5 | 13644.2 | 13654.2 | 1 | 137.2 | 1 | <0:0001 |


**Table 4: Estimations of Multivariate Model Parameters**
| Effect | Par. | Est. | S.E. | p-value |
|-|-|-|-|-|
| Intercept | β0 | -4.730 | 1.015 | <0.0001 |
| Age | β1 | 0.229 | 0.018 | <0.0001 |
| Time | β2 | -0.936 | 0.083 | <0.0001 |
| Age × Time | β3 | 0.016 | 0.001 | <0.0001 |
| Common Cov. |$\sigma^2_{1}$  | 54.371 | 3.691 |  |
| Res.Var. | $\sigma^2$ | 16.750 | 0.589 |  |


The parameter estimates of the final multivariate model are summarized in Table 4. It can be seen that age, time, and interaction effect between them were significant. This implies that age has a positive effect on hearing threshold which depends on time. At time 0, a unit change in age adds up a 0.229 unit on the mean response of hearing threshold. Whereas, as time increases this effect increases slowly because the coefficient of the interaction was small (0.016). In other words, as time increases the effect of age on hearing threshold also increases because the estimates were positive. In addition, Time has a negative effect on hearing threshold. Generally, the mean response has a significant increasing linear trend. Additionally, the common covariance was estimated to be 54.371 and residual variance 16.750. This figures can also be used to estimate the intra subject correlation of $\hat\rho= 54.371=(54.371 + 16.750) = 0.76$  . This has a meaning that the correlation between measurements within a subject measured at two different time points is 0.76, which can be classified as moderate high association. Since the fitted model was based on a compound symmetry covariance structure, this correlation is assumed to be constant between measurements measured at any pair of time points.

## Two Stage Analysis
### Stage-1 Model
In order to explore the adequacy of the linear model, linear and quadratic first stage regression models were fitted to each subject separately. In Figure 4 the subject-specific coefficients of multiple determination $(R_i^2)$ together with the overall coefficient of determination $(R_{meta}^{2})$ for both linear and quadratic subject specific profiles are presented .In the linear case, $(R_{meta}^{2})$ equals 0.5377 and in the quadratic case 0.6390. In both cases, the explained within-subject variability is not large and $(R_{meta}^{2})$ is expected to increase when the quadratic term is added. From the scatterplots of $(R_i^2)$ under both models, it is clear that still many subjects have a low subject-specific coefficient, which indicates that the profiles are not well described.

![](https://i.imgur.com/0dwPZtc.png)
**Figure 4: Scatterplots of $R_i^2$ under linear and quadratic model**


To check whether or not the squared term for time is important, the F-test comparing the linear versus quadratic model is conducted. Incorporating a quadratic term for the time-effect would not improve the model $(F_{333;837} = 0,9878, p-value = 0:5480)$. Therefore, the linear model, without quadratic term, is considered in further analysis. The stage 1 model, with hearing threshold $Y_{ij}$ for the $i^{th}$ subject $(i = 1,2,..,543)$, measured at time $ij$ is given by:
                    $$Y_{ij} = \beta_{0i}+\beta_{1i}Time_{ij} +\epsilon_{ij}$$
                    
Parameters $\beta_{0i}$ and $\beta_{1i}$ are the unknown subject-specific regression coefficients and $\epsilon_{ij}$ explains the withinsubject variability, with $\epsilon_{ij} \sim N(0,\sigma_{i}^2)$. As a result, the first stage modeling was fitting a linear regression of hearing threshold as a function of time independently for each subject. The subject specific parameter estimates, intercept $\beta_{0i}$ and slope $\beta_{1i}$, were assessed to check the between-subject variability of these estimates and their significance.

**Table 5: Summary of subject specific regression parameter estimates**

$Testing H0 : β_{k} = 0$
| Variable | Mean | S.E. | Min. | Max. | t-Value | p-value |
|-|-|-|-|-|-|-|
| Intercept$(\hat\beta_{0i})$ | 6.152 | 0.169 | -4.000 | 71.722 | 36.430 | <.0001 |
| Slope$(\hat\beta_{1i})$ | 0.256 | 0.020 | -6.750 | 7.368 | 13.080 | <.0001 |

In table 5 illustrates the average intercept and slope were 6.152 and 0.256 respectively. Also, the standard deviation of these estimates indicate that the variability was larger for the intercept (0.169) and relatively small for the slope (0.02). The slope estimates range from -6.75 to 7.368 and this implies that subjects with negative slope had a decreasing evolution of hearing threshold, where as for those subjects with positive slope the evolution was increasing. This statistically translates that subjects have different rate of evolution. Similarly, the intercept was ranging from -4 to 71.722 and this again implies that subjects have different intercepts. This in general suggests a random intercept and/or slope may be required for Generalized Linear Mixed modeling. The last two columns of Table [5] also shows that the average intercept and average slope were significantly different from 0 (p-value <.0001). However, these p-value was a border line p-value and inference based on this information may not be accurate.

### Stage-2 Model
After stage 1 finish, and to fit the second-stage model, the estimated subject specific intercepts and time effects from stage 1 are related to the baseline age of the subjects as covariate. The stage 2 model, with the subject-specific intercepts and time effect related to the age of the subjects is given by:
$$\beta_{0i} = \beta_{0} + \beta_{1}Age_{i} + b_{1i}$$
$$\beta_{1i} = \beta_{2} + \beta_{3}Age_{i} + b_{2i}$$

where $\beta_{0}$ and $\beta_{2}$ are, respectively, average intercept and average slope (linear time effect) corrected for age, $\beta_{1}$ is the linear age effect on the intercept, and $\beta_{3}$ is the linear age effect on the slope, while $b_i = (b_{1i} b_{2i})^T \sim N(0, D)$ is the between subject variability of intercept and slope.
Result from this analysis were presented in Table [6]. The results suggested that there is a significant positive age effect on the evolution of hearing thresholds. (p value <.0001)


**Table 6: Parameter Estimates for the Second Stage Model**
| Par. | Est. | S.E. | p-value |
|:-:|:-:|:-:|:-:|
| $\hat\beta_{0}$| -3.1352 | 0.5285 | <.0001 |
| $\hat\beta_{1}$ | 0.1652 | 0.0090 | <.0001 |
| $\hat\beta_{2}$ | -0.6921 | 0.0624 | <.0001 |
| $\hat\beta_{3}$ | 0.0169 | 0.0011 | <.0001 |

The variability in the random intercept was much larger as compared to the variability in the random slope as shown in Table 7. At the same time, a small possitive covariance between them was also observed. Hence, the evolution of those subjects who start with low hearing threshold is faster than those who start with high hearing threshold.

**Table 7: Variance Components from the Second Stage analysis**


| Effect1  | $b_{0}$| $b_{1}$|
| -------- | -------- | -------- |
| $b_{0}$    |61.448   | 0.044     |
| $b_{1}$    |0.044    | 0.828     |

However, information was lost in summarizing the repeated measurements by the estimated $\beta_{i}s$, for each subject separately[8]. At the same time, random variability was introduced by replacing $\beta_{i}s$ in the second-stage model by their estimates. Further more, the covariance matrix of $\beta_{i}s$ has not been taken into account in the second stage of the analysis as it highly depends on the number of measurements available for the ith subject as well as the time points at which these measurements were taken. Consequently, the more parsimonious method that can handle these problems such as the general linear mixed effects model is required.

## Random Effects Model
From the plot of variance structure (Figure 3), it was observed that the variance was not constant.This implies that random intercepts and measurement error only might not be enough to represent the variability, hence random slopes were also considered in the model. It is favored to include too many random effects rather than omitting them as this ensures that the remaining variability is not due to any missing random effects [8]. A mixture of χ2 with equal weights 0.5 for the hierarchical interpretation was done in order to make inferences about the variance components. Table [8] shows that both random intercept and slope are needed.

**Table 8: Random Effect Model Comparison**



|             Model             |   −2l   | Ref |        Mixture$\chi^2$         | p-value  |
|:-----------------------------:|:-------:| --- |:------------------------------:| -------- |
|      1) No random effect      | 15251.1 |     |                                |          |
|   2) Only random intercept    | 13531.0 | 1   | $P(\chi_{0:1}^{2} \ge 1720.1)$ | < 0.0001 |
| 3) Random intercept and slope | 13345.4 | 2   | $P(\chi_{0:1}^{2} \ge 1720.1)$ | < 0.0001 |
            
 
To assess the need for serial correlation, models with the same mean structures and random effects but different serial correlations such as Exponential, Power, and Gaussian were also considered. Table 9 shows that there were improvement by including Gaussian and exponential serial correlations in the model containing measurement error. Almost the same value was observed implying the absence of serial
correlation. This was in agreement with the information obtained from the semi variogram in Figure 3. Finally consider the following linear model with random intercept, random slope, and measurement error to be fitted.


$$Y_{ij}= \beta_{0} + \beta_{1}Age + b_{0i}
     + (\beta_{2} + \beta_{3}Age_{i} + b_{1i})t_{ij} + \epsilon_{(1)ij} $$

where age (in year) is the age of $ith$ patient at the time of entry into the study, $\epsilon_{(1)ij}$ is the measurement error.

**Table 9: Comparison of the REML log-likelihoods for different Serial Correlations**


|  Residual Covariance Structure  | -2 REML log-likelihood |
|:-------------------------------:|:----------------------:|
|     Only measurement error      |        13305.4         |
|  Measurement error + Gaussian   |        13304.5         |
| Measurement error + Exponential |        13304.8         |
 
 
 Table 10 shows that the average evolution of hearing threshold depends on time, age at start of experiment and interaction between age and time were positive and highly significant. This indicated that older subjects at the beginning have higher hearing thresholds compared to younger subjects and the hearing threshold increases for a subject over time, given his or her specific age. The evolution of hearing
threshold over time differed depending on their age. The estimated variance of the random intercepts was $d_{11} = 50.942$, which indicated a high between-subject variability at the start of the study. In addition, the residual variance was about 13 which reflected in a large within-subject variability. The covariance between random intercepts and slopes was found to be positive, which means that the higher the hearing threshold at the beginning, the more the hearing threshold is expected to increase over time.

Table 10 shows that the average evolution of hearing threshold depends on time, age at start of experiment and interaction between age and time were positive and highly significant. This indicated that older subjects at the beginning have higher hearing thresholds compared to younger subjects and the hearing threshold increases for a subject over time, given his or her specific age. The evolution of hearing threshold over time differed depending on their age. The estimated variance of the random intercepts was $d_{11} = 50.942$, which indicated a high between-subject variability at the start of the study. In addition,
the residual variance was about 13 which reflected in a large within-subject variability. The covariance
between random intercepts and slopes was found to be positive, which means that the higher the hearing
threshold at the beginning, the more the hearing threshold is expected to increase over time.

**Table 10: Parameter Estimates and S.E. for Final Random-Effects Model**

| Effect | Par. | Est. | S.E. | p-value |
|:-:|:-:|:-:|:-:|:-:|
| Intercept | $\beta_{0}$| -4.752 | 0.967 | <.0001 |
| Age | $\beta_{1}$ | 0.227 | 0.018 | <.0001 |
| Time | $\beta_{2}$ | -0.854 | 0.115 | <.0001 |
| Age × Time | $\beta_{3}$ | 0.014 | 0.002 | <.0001 |
| **Covariance of $b_i$** |  |  |  |  |
| Var$(b_{0i})$ | $d_{11}$ | 50.942 | - | - |
| Cov$(b_{0i},b_{1i})$ | $d_{12}=d_{21}$ | 0.165 | - | - |
| Var$(b_{1i})$ | $d_{22}$ | 0.176 | - | - |
| Residual variance | $\sigma_{res}^2$ | 12.831 | - | - |




## Conclusion and Recommendations
In conclusion, Parameter estimates obtained from a multivariate regression model, two-stage analysis, and random- effects model were in generally close to each other. In fact, there was little difference in parameter
estimates and standard errors from the multivariate regression and random-effects model. In addition, the same conclusion was for the 3 approaches resulted to , where age, time effect on hearing threshold and the interaction between them were found to be significant. An indication by the models that the patients hearing evolution depends on his/her age at entry into the study implying that correcting for age at entry in the study is important since younger patients tend to have lower hearing threshold than older patients. Patients who entered the study at relatively young age tended to have better (decreasing) hearing threshold with time. The findings of this study therefore confirm the common knowledge that hearing performance indeed deteriorates as one gets older, and this was reflected by an increase in the hearing threshold over time. Moreover, as seen patients differed in number of measurements, about 100 had only one and only one who have 14 measurements. This might have consequences on the efficiency of methods used. As observed in this study, there was restriction of the variance structure assumptions applied in the multivariate case. Also in this study there is the possibility of outlier influence which could have had consequences on the estimates. Finally, when studying hearing evolution, it is important to account for gender differences and risk factors including; family history, exposure to noise pollution, ototoxic medications, ear related infections, tumor disorders, as noted by [3].

## References

[1] Agresti, A. (2003). Categorical data analysis (Vol. 482). John Wiley & Sons.\
[2] Gates, G. A., & Mills, J. H. (2005). Presbycusis. The lancet, 366(9491), 1111-1120.\
[3] Goines L. and Hagler, L. (2007). Noise Pollution: A Modern Plague. Southern Medical Journal.100(3):287-294.\
[4] Huang, Q., & Tang, J. (2010). Age-related hearing loss or presbycusis. European Archives of Oto-rhinolaryngology, 267(8), 1179-1191.\
[5] Liang, K. Y., & Zeger, S. L. (1986). Longitudinal data analysis using generalized linear models.Biometrika, 73(1), 13-22.\
[6] Molenberghs, G. and Verbeke, G. (2005), Models for Discrete Longitudinal Data, Springer.\
[7] Singer, D. and Willett, B. (2003). Applied Longitudinal Data Analysis: Modeling Change and Event Occurrence. New York: Oxford University Press, Inc.\
[8] Verbeke, G. and Molenberghs, G.. Linear mixed models for longitudinal data. Springer Science & Business Media, 2000.\
[9] World Health Organization. Deafness and hearing loss. https://www.who.int/news-room/factsheets/detail/deafness-and-hearing-loss, Updated: March 01, 2020. [Online; accessed 20-October- 2020].