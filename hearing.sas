libname lda "C:\Users\NSOH TANIH\OneDrive\";

/* Importing Dataset */
proc print data="hearing1000.sas7bdat";
run;

PROC SORT DATA=lda.hearing1000;
	BY id age;
RUN;
/**********************************************************************************/
/* Summary of Followup */
/**********************************************************************************/
proc freq data=lda.hearing1000;
	table Id/nocum norow nopercent nocol out=patients;
run;

proc freq data=patients;
	table count/nocum norow nopercent nocol;
run;

/* First Visit for Each Patient */
DATA FIRST;
SET lda.hearing1000;
	BY id;
	IF FIRST.id;
RUN;

proc means median data=first;
run;

/* Number of Visits for Each Patient */
DATA nvisits;
SET lda.hearing1000;
	BY id;
	IF FIRST.id THEN VISIT = 1;
	ELSE VISIT + 1;
RUN;

/*  Time Since First Visit in The Study (years) for Each Patient */
Data tfvisit;
Set lda.hearing1000;
	By id;
	Retain first_value;
	If first.id then 
	First_value=age;
	time = age - first_value;
	timecls=round(time,1);
	time2=time*time;
	age2=age*age;
	if age>15 & age<=40 then agegroup=1;
	if age>40 & age<=65 then agegroup=2;
	if age>65 then agegroup=3;
	DROP first_value;
	OUTPUT;
Run;

proc freq data=tfvisit;
	table timecls/nocum norow nopercent nocol out=patients;
run;

proc means median data=tfvisit;
run;

/**********************************************************************************/
/* Graphical Exploratory Data Analysis */
/**********************************************************************************/
*Selecting ID randomly;
proc sort data=tfvisit;
	by id;
run;

data random;
	do ID=1 to 543;
	output;
	end;
run;

proc surveyselect data=random
	method=srs n=100 out=hearing_rs noprint seed=10;
run;

data randomlyselected;
	merge hearing_rs(in=a) tfvisit;
	by ID;
	if a;
run;

/* Individual Profile */
*individual profile of the randomly selected 100 individuals;
goptions reset=all i=join noborder;
Proc gplot data=randomlyselected;;
	plot y*time=id/nolegend haxis=axis1 vaxis=axis2;*noframe;
	axis1 label=(h=1'Time since entry (years)') order=(0 to 25 by 5) minor=none;
	axis2 label=(h=1 A=90 'Sound pressure level (in dB)') minor=none;
run;
quit;


/* Mean and variance structure */
*Since the data is unbalanced, a smoothing technique(non parametric approach) more helpfull to estimate the average evolution;
proc loess data=tfvisit;
	ods output scoreresults=scores;
	model y=time;
	score data=tfvisit;
run;

proc sort data=scores;
	by time;
run;

*smoothing plot without considering age;
goptions reset=all;
proc gplot data=scores;
	title2 'Loess smoothing - Overall';
	plot y*time=1 p_y*time=2/overlay haxis=axis1 vaxis=axis2;
	symbol1 c=red v=dot h=0.6 mode=include;
	symbol2 c=black i=join w=2 mode=include;
	axis1 label=(h=1 'Time since entry (years)') minor=none;
	axis2 label=(h=1 A=90 'Hearing thresholds (dB)') minor=none;
run;
quit;

*smoothing plot by age group;
*For Age: 15-40 group 1; *For Age:41-65 group 2; *For Age: >65 group 3;
proc sort data=tfvisit;
	by agegroup;
run;

proc loess data= tfvisit;
	ods output scoreresults=combinedscores;
	model y=time/ smooth=0.4;
	by agegroup;
	score data=tfvisit;
run;

proc sort data=combinedscores;
	by agegroup time;
run;

proc gplot data=combinedscores;
by agegroup;
plot y*time=1 p_y*time=2/overlay haxis=axis1 vaxis=axis2;
title2 'Loess smoothing - AgeGroup';
symbol1 c=red v=dot h=0.9 mode=include;
symbol2 c=black i=join w=2 mode=include;
axis1 label=(h=1 'Time since entry (years)') minor=none;
axis2 label=(h=1 A=90 'Hearing thresholds (dB)') minor=none;
title;
run;
quit;

/* Variance structure */
data res2;
	set scores;
	rij2=(y-p_y)**2;
	keep time rij2;
run;

proc loess data=res2;
	ods output scoreresults=res_scores;
	model rij2=time;
	score data=res2;
run;

goptions reset=all;
proc gplot data=res_scores;
plot rij2*time=1 p_rij2*time=2/overlay haxis=axis1 vaxis=axis2;
	title2 h=2 'Smoothed Variance Function';
	symbol1 c=violet v=dot h=0.3 mode=include;
	symbol2 c=black i=join w=2.5 mode=include;
	axis1 label=(h=1 'Time since entry (years)') minor=none;
	axis2 label=(h=1 A=90 'Squared residuals') minor=none;
run;
quit;

/*Correlation Structure -Semi-Variogram*/
/* Calculation of residuals, linear average trend */
proc glm data=tfvisit;
	model y=age time age*time;
	output out=outv r=residual;
run;

/* Calculation of the variogram */
proc variogram data=outv outpair=outv;
	coordinates xc=time yc=id;compute robust novariogram;
	var residual;
run;

data variogram;
	set outv;
	if y1=y2;
	vario=(v1-v2)**2/2;
run;

data variance;
set outv;
if y1<y2; vario=(v1-v2)**2/2;
run;

/* Calculation of the total variance (=75.2245941) */
proc means data=variance mean;
	var vario;
run;

/* Loess smoothing of the variogram */
proc loess data=variogram;
	ods output scoreresults=outv2;
	model vario=distance;
	score data=variogram;
run;

proc sort data=outv2;
	by distance;
run;

proc means data=outv2;
	var vario distance;
run;

goptions reset=all;
proc gplot data=outv2;
	title2 h=2 'Semi-variogram';
	plot vario*distance=1 p_vario*distance=2/overlay haxis=axis1 vaxis=axis2 vref=75.2245941 lvref=2 wvref=2 cvref=black;
	symbol1 c=red v=dot h=0.3 mode=include;
	symbol2 c=black i=join w=2 mode=include;
	axis1 label=(h=1 'Time since entry in the study (years)') 
	order=(0 to 24 by 4) minor=none;
	axis2 label=(h=1 A=90 'Semi-variogram (v(u))')  minor=none;
run;
quit;

/**********************************************************************************/
/* Summary Statistics */
/**********************************************************************************/
proc sort data=tfvisit;
    by id;
run;

/* Difference Dataset between obs_1 and obe_n */
data obs_1 obs_n; 
set tfvisit;
	by id;
	if first.id then output obs_1;
	if last.id then output obs_n;
run;


/*Analysis of Increaments using age as a covariate*/
data diff;
	merge obs_1(rename=(y=y_1 time=time_1)) obs_n(rename=(y=y_n time=time_n));
	by id;
	D=y_n - y_1;
run;

proc reg data=diff;
    title2 'Analysis of Increaments';
    model D=age;
run;

/* Analysis of covariance */
proc reg data=diff;
	title2 'Analysis of covariance';
	model y_n=age y_1;
run;

/* Analysis of Area Under the Curve */
data AUCarea;
set tfvisit;
	by ID;
	prevTime = lag(time);
	prevMsr = lag(y);
	timeDiff = time - prevTime;
	areaRect = timeDiff * (y + prevMsr)/2;
	if first.ID then do;
	prevMsr = .;
	timeDiff = .;
	areaRect = .;
	end;
run;

proc means data=AUCarea sum noprint;
	class ID;
	var areaRect;
	output out=AUC01 sum=AUC;
run;

data AUC02;
	merge AUC01(where=(ID ne .)) AUCarea;
	by ID;
	drop _type_ _freq_;
run;

data AUC02;
	merge AUC01(where=(ID ne .)) AUCarea;
	by ID;
	drop _type_ _freq_ time y prevtime prevmsr timediff areaRect;
run;

proc sql;
	create table AUC03 as select distinct * from AUC02;
quit;

/* Simple linear regression over AUC using age as a covariate*/
proc reg data=AUC03;
	title2 'Analysis of AUC';
	model auc=age;
run;

/**********************************************************************************/
/* Multivariate Model */
/**********************************************************************************/
data MVM;
set tfvisit;
run;

proc mixed data=MVM covtest method=ml;
	title2 'Multivariate Model 1';
	class id timecls;
	model y = age time age*time/ solution;
	repeated timecls / type=cs subject=id;
run;

proc mixed data=MVM covtest method=ml;
	title2 'Multivariate Model 2';
	class id timecls;
	model y = age time/ solution;
	repeated timecls / type=cs subject=id;
run;

proc mixed data=MVM covtest method=ml;
	title2 'Multivariate Model 3';
	class id timecls;
	model y = age age*time/ solution;
	repeated timecls / type=cs subject=id;
run;


proc mixed data=MVM covtest method=ml;
	title2 'Multivariate Model 4';
	class id timecls;
	model y = time age*time/ solution;
	repeated timecls / type=cs subject=id;
run;


/* LRT for Parameter Reduction in Multivariate model */
data LRT; *model 1 with model 2;
L01 = 13646.7 - 13507;
df =1;
pval=1-probchi(L01, 1);
run;

data LRT; *model 1 with model 3;
L02 = 13630.4- 13507;
df =1;
pval=1-probchi(L02, 1);
run;

data LRT; *model 1 with model 4;
L03 = 13644.2-13507;
df =1;
pval=1-probchi(L03, 1);
run;

/**********************************************************************************/
/* Two Stages Analysis */
/**********************************************************************************/
/* 1st Stage */
proc sort data=tfvisit;
    by id;
run;

proc reg data=tfvisit outest=lsepreg rsquare noprint;
    model y = time/SSE;
    by id;
run;

proc freq data=tfvisit noprint;
    table id/out=count;
run;

proc reg data=tfvisit outest=qsepreg rsquare noprint;
    model y = time time2/SSE;
    by id;
run;

data comb;
	merge lsepreg(rename=(_SSE_=_SSE_l _RSQ_=_RSQ_l _EDF_=_EDF_l)) qsepreg(rename=(_SSE_=_SSE_q _RSQ_=_RSQ_q _EDF_=_EDF_q)) count(rename=(count=ni));
	by id;
	_SSTO_l=_SSE_l/(1-_RSQ_l);
	_SSTO_q=_SSE_q/(1-_RSQ_q);
	keep _SSE_q _RSQ_q _SSTO_q _EDF_q _SSE_l _RSQ_l _SSTO_l _EDF_l ni;
run;

proc means data=comb noprint sum;
	var _SSE_l _SSTO_l _EDF_l;
	where ni GE 2;
	output out=LMeta(drop=_TYPE_ rename=(_FREQ_=_FREQ_l)) sum=;
run;

proc means data=comb noprint sum;
	var _SSE_q _SSTO_q _EDF_q;
	where ni GE 3;
	output out=QMeta(drop=_TYPE_ rename=(_FREQ_=_FREQ_q)) sum=;
run;

/* To compute R-squared meta */
data RMeta;
	merge LMeta QMeta; R2Meta_l=1-_SSE_l/_SSTO_l; R2Meta_q=1-_SSE_q/_SSTO_q;
	keep R2Meta_l R2Meta_q;
run;

/* To compute F meta statistic */
proc means data=comb sum noprint;
	var _SSE_l _SSTO_l _EDF_l _SSE_q _SSTO_q _EDF_q; where ni GE 3;
	output out=FMeta sum=;
run;

data Fcal;
set Fmeta;
	FLQ=((_SSE_l-_SSE_q)/(_EDF_l-_EDF_q))/(_SSE_q/_EDF_q);
	DFn=_EDF_l-_EDF_q;
	DFd=_EDF_q;
	keep FLQ DFn DFd;
run;


/* R2-Plot For linear */ * F_meta=0.538;
goptions reset=all;
proc gplot data=comb;
	plot _RSQ_l*ni/haxis=axis1 vaxis=axis2 vref=0.538 lvref=3;
	symbol1 height=0.8 value=dot;
	axis1 label=(h=1 'Number of ni of measurements')  minor=none;
	axis2 label=(h=1 A=90 'Coefficient Ri2')  minor=none;
	title2 'Linear Model'
run;

/* R2-Plot For quadratic */ * F_meta=0.639;
goptions reset=all;
proc gplot data=comb;
	plot _RSQ_q*ni/haxis=axis1 vaxis=axis2 vref=0.639 lvref=3;
	symbol1 height=0.8 value=dot;
	axis1 label=(h=1 'Number of ni of measurements')  minor=none;
	axis2 label=(h=1 A=90 'Coefficient Ri2')  minor=none;
	title2 'Quadratic Model';
run;

data first_a;
set lsepreg;
	rename Intercept=b0 time=b1;
	keep id intercept time;
run;

data hearing_a;
set tfvisit;
	keep id age;
run;

proc sql;
create table hearing_b as select distinct * from hearing_a;
quit;

data First_stage;
	merge hearing_b first_a;
	by ID;
run;

proc means data=First_stage mean std stderr min max t probt;
var b0 b1;
run;


Data specific;
	merge lsepreg(rename=(Intercept=B0i time=Bli)) tfvisit;
    by id;
run;

proc print data=specific;
run;

/* second-stage analysis */
/* Here from the plot, it seams like age has a quadratic effect only on B0i */
proc reg data=specific;
	model B0i=age/;
	output out=beta0 r=b0i;
run;

proc reg data=specific;
	model Bli=age/;
	output out=beta1 r=bli;
run;

Data rand_beta;
	merge beta0 beta1;
	by id;
	keep id b0i bli;
run;

proc corr data=rand_beta cov;
	var b0i bli;
run;

/* Plot of slope vs Intercept from two-stage analysis */
data lsepreg;
	set lsepreg;
	Slope=time;
	keep Intercept Slope;
run;

proc gplot data=lsepreg;
plot TIME*intercept/haxis=axis1 vaxis=axis2 nolegend;
axis1 label=('Random intercept') value=(h=1.2);
axis2 label=(A=90 'Random slope') value=(h=1.2);
title h=1 'Random slope by Intercept';
run;

/**********************************************************************************/
/* Random Effects Model */
/**********************************************************************************/
data hear_re;
set tfvisit;
	t=time;
run;

proc mixed data=hear_re method=reml; *(-2 Res Log Likelihood 15251.1);
	class time id;
	model y=age t age*t/ solution;
	repeated time/type=simple subject=id;
run;

proc mixed data=hear_re method=reml; *(-2 Res Log Likelihood 13531.0);
	class time id;
	model y=age t age*t/ solution;
	random intercept /type=cs subject=id;
	repeated time/type=simple subject=id;
run;
 
proc mixed data=hear_re method=reml; *(-2 Res Log Likelihood 13345.4);
	class time id;
	model y=age t age*t/ solution;
	random intercept t /type=csh subject=id;
	repeated time/type=simple subject=id;
run;

/* LRT for Parameter Reduction in Multivariate model */
data LRT; *No random effect vs. Random intercept;
L01 = 15251.1 - 13531.0;
df1 =0;
pval1=1-probchi(L02, df1);
df2 =1;
pval2=1-probchi(L02, df2);
pval = (pval1+pval2)/2;
run;

data LRT; *Random intercept vs. Random intercept + Random Slop;
L02 = 13531.0-13345.4;
df1 =1;
pval1=1-probchi(L02, df1);
df2 =2;
pval2=1-probchi(L02, df2);
pval = (pval1+pval2)/2;
run;

/* Assessing serial correlation */
/* Only measurement error - No serial correlation*/
proc mixed data=hear_re method=reml covtest; *(-2 Res Log Likelihood 13305.4);
	class time id;
	model y=age t age*t/ solution;
	random intercept t /type=un subject=id;
	repeated time/type=simple subject=id;
run;

/* Exponential serial correlation*/
proc mixed data=hear_re method=reml covtest; *(-2 Res Log Likelihood 13304.5);
	class time id;
	model y=age t age*t/ solution;
	random intercept t /type=un subject=id;
	repeated time/type=sp(exp) (time)  local subject=id;
run;

/* Gussian serial correlation*/
proc mixed data=hear_re method=reml covtest; *(-2 Res Log Likelihood 13304.8);
	class time id;
	model y=age t age*t/ solution;
	random intercept t /type=un subject=id;
	repeated time/type=sp(gau) (time) local subject=id;
run;

data LRT; *Only measurement error vs. Only measurement error + Exponential serial correlation;
L02 = 13345.4-13301.8;
df1 =0;
pval1=1-probchi(L02, df1);
df2 =1;
pval2=1-probchi(L02, df2);
pval = (pval1+pval2)/2;
run;

data LRT; *Only measurement error vs. Only measurement error + Gussian serial correlation;
L02 = 13345.4-13301.8;
df1 =0;
pval1=1-probchi(L02, df1);
df2 =1;
pval2=1-probchi(L02, df2);
pval = (pval1+pval2)/2;
run;

/* Final Model */
proc mixed data=hear_re method=reml;
class time id;
model y=age t age*t/ solution chisq;
random intercept t /type=un subject=id g v gcorr vcorr solution;
repeated time/type=simple subject=id r rcorr;
ODS output SolutionR=RandUSave;
run;

proc print data=RandUSave;
run;

/* comparison with two stage */
proc transpose data=RandUSave out=rand prefix=random; 
	by id;
	id Effect;
	var Estimate;
run;


Data compare;
	merge beta0 beta1 rand;
	by id;
	diff_slop = randomt-bli ;
	diff2_int = randomintercept-b0i;
	keep id b0i bli randomintercept randomt diff_slop diff2_int;
run;


/* Random intercept and twostage intercept */
goptions reset=all;
proc gplot data=compare;
	plot b0i*randomintercept/overlay haxis=axis1 vaxis=axis2;
	symbol c=black v=dot h=0.6 mode=include;
	axis1 label=(h=1 'Intercept from Random effects model') value=(h=1) minor=none;
	axis2 label=(h=1 A=90 'Intercept from two stage analysis') value=(h=1) minor=none;
	title h=2 " Subject-specific intercepts ";
run;

/* Random Slope and twostage slope */
goptions reset=all;
proc gplot data=compare;
	plot bli*randomt/overlay haxis=axis1 vaxis=axis2;
	symbol c=black v=dot h=0.6 mode=include;
	axis1 label=(h=1 'Slope from Random effects model') value=(h=1) minor=none;
	axis2 label=(h=1 A=90 'Slope from two stage analysis') value=(h=1) minor=none;
	title h=2 " Subject-specific slopes ";
run;

/* Scatter plot between random sloape and random intercep */
goptions reset=all;
proc gplot data=compare;
	plot randomintercept*randomt/overlay haxis=axis1 vaxis=axis2;
	symbol c=black v=dot h=0.6 mode=include;
	axis1 label=(h=1 'Random slope ') value=(h=1)
	order=(-0.2 to 0.4 by 0.2 ) minor=none;
	axis2 label=(h=1 A=90 ' Random intercept ') value=(h=1) minor=none;
	title h=2 " Random slop vs Random intercept ";
run;

/* correlation between random sloape and random intercep */
proc corr data=compare;
	var randomintercept randomt ;
run;




