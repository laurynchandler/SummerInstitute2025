## exploring different parameterizations of our regression models

#### RTS ####
## most complex hierarchical model for RTs: random slope for a 3-way interaction with random intercept for subject
inference_rt_lm_hier <- df_inf %>% left_join(., df_trueCue_trends, by=c('subID', 'trueCue')) %>%
  lmer(zlogRT ~ logTrial.trend*congCue*accuracyFactor + (1+logTrial.trend*congCue*accuracyFactor|subID), .,
       control = lmerControl(optimizer = 'bobyqa', boundary.tol = 1e-10)) 
summary(inference_rt_lm_hier)

## hierarchical with uncorrelated random effects
inference_rt_lm_hier_uncorr <- df_inf %>% left_join(., df_trueCue_trends, by=c('subID', 'trueCue')) %>%
  lmer(zlogRT ~ logTrial.trend*congCue*accuracyFactor + (1+logTrial.trend*congCue*accuracyFactor||subID), .,
       control = lmerControl(optimizer = 'bobyqa', boundary.tol = 1e-10)) 
summary(inference_rt_lm_hier_uncorr) ## this does not achieve our desired goal of getting the degrees of freedom to match the number of subjects

## try removing logTrial.trend from the random slope
inference_rt_lm_hier2 <- df_inf %>% left_join(., df_trueCue_trends, by=c('subID', 'trueCue')) %>%
  lmer(zlogRT ~ logTrial.trend*congCue*accuracyFactor + (1+congCue*accuracyFactor|subID), .,
       control = lmerControl(optimizer = 'bobyqa', boundary.tol = 1e-10)) 
summary(inference_rt_lm_hier2)

## try fitting the full hierarchical model on subject means?
summary_df %>%
  lm(meanRT ~ logTrial.trend*congCue*accuracyFactor, .) %>% summary() # still does not give us DFs corresponding to number of subjects

## try removing accuracy from the interaction
inference_rt_lm_hier_noAcc <- df_inf %>% left_join(., df_trueCue_trends, by=c('subID', 'trueCue')) %>%
  lmer(zlogRT ~ logTrial.trend*congCue*accuracyFactor + (1+congCue*logTrial.trend|subID), .,
       control = lmerControl(optimizer = 'bobyqa', boundary.tol = 1e-10)) 
summary(inference_rt_lm_hier_noAcc)

## try using just congruence*condition instead of congCue as the predictor
inference_rt_lm_hier3 <- df_inf %>% mutate(condition = factor(condition, levels=c('condition_80cue', 'condition_65cue'),
                                                              labels=c('80/50 condition', '65/50 condition'))) %>%
  left_join(., df_trueCue_trends, by=c('subID', 'trueCue', 'condition')) %>%
  lmer(zlogRT ~ logTrial.trend*accuracyFactor*condition + (1+logTrial.trend*accuracyFactor*condition|subID), .,
       control = lmerControl(optimizer = 'bobyqa', boundary.tol = 1e-10)) 
summary(inference_rt_lm_hier3) # still fails to converge, this time with 4(!) negative eigenvalues

#### CHANGING SLOPE ESTIMATE TO BE FOR ALL CUES, INSTEAD OF SPLITTING BY CUE: FITTING RTS ####
inference_rt_lm_simpleTrend <- df_inf %>% 
  lmer(zlogRT ~ simpleTrend*congCue*accuracyFactor + (1+simpleTrend*congCue*accuracyFactor|subID), .) 
summary(inference_rt_lm_simpleTrend)

emmip(inference_rt_lm_simpleTrend, congCue ~ simpleTrend | accuracyFactor, CIs=T, at=list(congCue=unique(df_inf$congCue),
                                                                                   simpleTrend=unique(df_inf$simpleTrend)))


df_learning_trends %>% ggplot(aes(x=simpleTrend)) + 
  geom_histogram(bins = 10, color='gray') + facet_wrap(~condition) + theme_bw()


#### CONFIDENCE ####
inference_conf_lm_hier <- df_inf %>% left_join(., df_trueCue_trends, by=c('subID', 'trueCue')) %>%
  lmer(zconf ~ logTrial.trend*congCue*accuracyFactor + (1+logTrial.trend*congCue*accuracyFactor|subID), .,
       control = lmerControl(optCtrl=list(maxfun=20000))) 

summary(inference_conf_lm_hier)


### with just the simple learning Rt slope
inference_conf_lm_simpleTrend <- df_inf %>% 
  lmer(zconf ~ simpleTrend*congCue*accuracyFactor + (1+simpleTrend*congCue*accuracyFactor|subID), .) # this one failed to converge with 2 negative eigenvalues
summary(inference_conf_lm_simpleTrend)

emmip(inference_conf_lm_simpleTrend, congCue ~ simpleTrend | accuracyFactor, CIs=T, at=list(congCue=unique(df_inf$congCue),
                                                                                          simpleTrend=unique(df_inf$simpleTrend)))
