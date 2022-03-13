breed [persons person]
breed [hospitals hospital]
breed [groceries grocery]
breed [commutes commute]
breed [workplaces workplace]
breed [leisures leisure]

globals[
  ;sdp ;not used
  maskcnt
  asymptomatic-chance ;Added by AIC
  severe-chance ;Added by AIC
  recovery
  distribution
  speed
  rand-x
  rand-y
  hour
  hourly
  curfew?
  zerohour
  comorbid-risk-mod
  senior-risk-mod
  days
  deaths
  total-cases
  recoveries
  senior-deaths
  comorbid-deaths
  q-task
  grocery-radius
  commute-radius
  healthcare-radius
  workplace-radius
  leisure-radius
  reinfections
  vaccinations ;number of people who were successfully vaccinated ;Added by AIC
  vax-goal ;number of people to be vaccinated before going to the next priority group ;added by AIC
  vax-count ;tracks the number of people supposed to be vaccinated ;added by AIC
  vax-group ;Notes which group should be vaccinated next ;added by AIC
  infect-count-work
  infect-count-grocery
  infect-count-commute
  infect-count-hospital
  infect-count-leisure
  infect-count-else
  test1
  test2
]

persons-own [
  infectious-time
  social-distancing? ;not really used
  infected?
  asymptomatic? ;Added by AIC
  severe? ;Added by AIC
  mask?
  faceshield?
  comorbidity?
  senior?
  healthcare-worker?
  essential-worker?
  ordinary-citizen?
  relative-risk
  y-home
  x-home
  task ;can be a string or a switch, will represent where the agent needs to go. current working task
  taskt
  facility
  in-facility? ;checks if the patch being stood on is in the facility. Will turn on random movement if within facility
  task-duration ;the duration of the activity. Visit will be shorter, working there will be longer
  task-time  ;the amount of time that the turtle has actually spent in the facility
  task1
  task2
  task3
  task1t ;a boolean determining if task 1 will have the duration of a visit or a longer duration
  task2t ;a boolean determining if task 2 will have the duration of a visit or a longer duration
  task3t ;a boolean determining if task 3 will have the duration of a visit or a longer duration
  taskcnt ;a counter for which task is active
  ;VR ;ventilation rate of where the agent is ;not used
  ;Volume ;volume of space where the agent is present ;not used
  ;RQEF ;relative quanta emission factor ;not used
  ;RBRF ;relative breathing rate factor ;not used
  ppe-efficiency
  relative-death-chance ;death chance dependent on health category
  recovery-time ;time until recovery
  recovered-time ;time after recovery to get vaccine ;added by AIC
  exposed?
  exposed-time
  times-infected
  ;immune? ;immunity replaced with resistance
  relative-susceptibility
  vaccinated? ;added by AIC
  vax-efficacy ;added by AIC
]

patches-own[
  grocery-patch?
  hospital-patch?
  commute-patch?
  workplace-patch?
  leisure-patch?
]

to randomize-spawn
  set rand-x random-xcor
  set rand-y random-ycor
  setxy rand-x rand-y
  while [pcolor != 0 ]
  [ set rand-x random-xcor
    set rand-y random-ycor
    setxy rand-x rand-y]
end

to setup
  ;if tick-represents = "1 Day" [set recovery 14 set distribution 3 set speed 20] ;not used
  ;if tick-represents = "15 Minutes" [set recovery 1344 set distribution 288 set speed 5 set zerohour 96] ;not used
  if tick-represents = "3 Minutes" [set recovery 6720 set distribution 250 set speed 1 set zerohour 480]
  set curfew? true
  set days 0
  set deaths 0
  set recoveries 0
  set hour 0
  set maskcnt 0
  clear-ticks
  clear-patches
  clear-turtles
  plotxy 0 0
  plot-pen-down
  create-hospitals 1[setxy (max-pxcor / 2) (max-pycor / 2) set color blue]
  create-commutes 1 [setxy 0 0 set color blue]
  create-groceries 1 [setxy (-(max-pxcor / 2)) (-(max-pycor / 2)) set color blue]
  create-workplaces 1 [setxy (-(max-pxcor / 2)) (max-pycor / 2) set color blue]
  create-leisures 1 [setxy (max-pxcor / 2) (-(max-pycor / 2)) set color blue]
  setup-patch-area
  setup-patches
  set infect-count-work 0
  set infect-count-grocery 0
  set infect-count-commute 0
  set infect-count-hospital 0
  set infect-count-leisure 0
  set infect-count-else 0

  ;give pen a new color if a new social distancing percentage has been set
  ;if social-distancing-percentage != sdp [set-plot-pen-color (random 14 * 10 + random 3 + 4)]
  create-persons total-population [
    set shape "person"
    ;set shape "turtle" ;for fun
    set size 2

    randomize-spawn

    ;set rand-x random-xcor
    ;set rand-y random-ycor
    ;setxy rand-x rand-y

    set color green ;all people are originally created as susceptible and non-stationary
    set infectious-time 0
    set social-distancing? false
    set mask? false
    set faceshield? false
    set comorbidity? false
    set senior? false
    set healthcare-worker? false
    set essential-worker? false
    set ordinary-citizen? false
    set y-home rand-y
    set x-home rand-x
    ;set task "workplace"
    set taskcnt 1
    set taskt 50
    set recovery-time 0
    set exposed-time 0
    set infected? false ;added by AIC
    set asymptomatic? false ;added by AIC
    set severe? false ;added by AIC
    set exposed? false
    set times-infected random 3
    if times-infected > 0 [set recovered-time random-normal 28280 1000]
    ;set immune? false ;added by AIC
    set relative-susceptibility ( ( 1 / 5 ) ^ times-infected )
    set vaccinated? false ;added by AIC
  ]

;  ask n-of random-normal (total-population / 2) 100 persons[
;    set times-infected random 3
;  ]

  ask n-of starting-infected persons [
    get-sick
    set infectious-time random-normal (recovery * 0.66) distribution
  ] ;begin with some infected people
  set total-cases starting-infected

  ask n-of comorbidity-count persons[
    set comorbidity? true
  ]

  ask n-of senior-count persons with [comorbidity? = false][
    set senior? true
  ]

  ;ask n-of healthcare-worker-count persons with [social-distancing? = false and senior? = false] [
  ask n-of healthcare-worker-count persons with [senior? = false] [
    set healthcare-worker? true
  ]

  ;ask n-of essential-worker-count persons with [social-distancing? = false and healthcare-worker? = false and senior? = false][
  ask n-of essential-worker-count persons with [healthcare-worker? = false and senior? = false][
   set essential-worker? true
  ]

  ask persons with [healthcare-worker? = false and essential-worker? = false and senior? = false][
    set ordinary-citizen? true
  ]

  set vaccinations 0
  set vax-count 0
  set vax-goal healthcare-worker-count
  set vax-group 1
  ask n-of starting-vax-count persons with [color != red][
    vaccinate
  ] ;added by AIC

  ;setting up mask bois
  ;ask n-of ((total-population - starting-infected) * mask-wear-percent / 100) persons with [color != red] [
  ask n-of ((total-population) * mask-wear-percent / 100) persons [
    set shape "maskman"
    set mask? true
    set maskcnt (maskcnt + 1)
  ]

  ;setting up shield bois
   ask n-of (maskcnt * mask-wear-faceshield-percent / 100) persons with [shape = "maskman"] [
    set shape "shieldman"
    set faceshield? true
    ;set mask? true
  ]

  set-ppe-efficiency
  set-relative-death-chance
  set-relative-risk
  reset-ticks

  if quarantine-level = "GCQ" [ask persons [gcq-assign-task]]
  if quarantine-level = "MECQ" [ask persons [mecq-assign-task]]
  if quarantine-level = "ECQ" [ask persons [ecq-assign-task]]

  set comorbid-risk-mod 1.2
  set senior-risk-mod 1.2
  set asymptomatic-chance 0.2 ;added by AIC
  set severe-chance 0.01 ;added by AIC
end

to go
  ;to remember the user-defined social distancing percentage
  ;set sdp social-distancing-percentage
  move
  infect
  recover
  count-deaths
  set-exposed
  ;stop the simulation and plot when there are no more infected people
  if not any? persons with [infected? = true] [stop]
  if maximum-days != 0 [if (days - 1) >= maximum-days [stop]]

  if ticks mod zerohour = 0 [
    if quarantine-level = "GCQ" [ask persons [gcq-assign-task]]
    if quarantine-level = "MECQ" [ask persons [mecq-assign-task]]
    if quarantine-level = "ECQ" [ask persons [ecq-assign-task]]
    ;ask persons[mecq-assign-task]
    set days days + 1
  ]
  ;setting clock

  if tick-represents = "3 Minutes"[set hourly 20]
  ;if tick-represents = "15 Minutes"[set hourly 4]

   if ticks mod hourly = 0 [set hour (hour + 1)]
   if hour = 24 [
    vax-priority
    ask persons with [infected? = false and times-infected > 0] [
      set recovered-time (recovered-time + 1)
    ]
    set hour 0
    ask persons [set taskcnt 1]
  ]

  ifelse hour < curfew-hours [
    set curfew? true
  ][
    set curfew? false
  ]
  ;check-relative-risk
  commuting
  workplacing
  grocerying
  hospitaling
  leisuring
  gohome
 tick
end

to move
ifelse curfew? = true[
    ask persons[set task "stayhome"]
    ask persons[set task-time 0]
  ][do-task]
end

to-report nearby-hospitals
  report min-one-of hospitals [distance myself]
end


to set-ppe-efficiency
  ask persons with [healthcare-worker? = true]
  [
    set ppe-efficiency 0.95
  ]
  ask persons with [healthcare-worker? = false]
  [
    set ppe-efficiency random-normal 0.3 0.1
    if faceshield? = true [set ppe-efficiency (ppe-efficiency * 1.15)]
  ]
end

to set-relative-risk
  ask persons [
    ;modifies relative risk based on health category
    set relative-risk (base-infection-risk)
    if senior? = true [set relative-risk (base-infection-risk * senior-risk-mod)]
    if comorbidity? = true [set relative-risk (base-infection-risk * comorbid-risk-mod)]
    ;modifies relative risk based on ppe
    if mask? = true [set relative-risk (relative-risk * (1 - ppe-efficiency))]
    set relative-risk (relative-risk * relative-susceptibility)
  ]
end

;to check-relative-risk ;removed because it resets relative-risk
  ;ask persons [
    ;ifelse exposed? = true [set relative-risk base-infection-risk] [set relative-risk (base-infection-risk / 10)]
  ;]
;end

to infect
  ask persons with [infected? = true] [
    set infectious-time (infectious-time + 1)
    ;susceptibe people are infected with some probability if they're close enough to an infected person
    ifelse mask? = false [
      ifelse pcolor != black [
        ask persons with [infected? = false] in-radius 1.33 [
          if random-float 1 < relative-risk [get-sick]
        ]
      ][
        ask persons with [infected? = false] in-radius 0.133 [
          if random-float 1 < relative-risk [get-sick]
        ]
      ]
    ][
      ifelse pcolor != black [
        ask persons with [infected? = false] in-radius 1.33 [
          if random-float 1 < (relative-risk * random-normal 0.4 0.1) [get-sick] ;Find out actual chances if infected has mask
        ]
      ][
        ask persons with [infected? = false] in-radius 0.133 [
          if random-float 1 < (relative-risk * random-normal 0.4 0.1) [get-sick] ;Find out actual chances if infected has mask
        ]
      ]
    ]
  ]
end

to get-sick
  set infected? true
  ifelse random-float 1 < ( asymptomatic-chance / relative-susceptibility) [
    set asymptomatic? true
    set color orange
  ][
    set color red
    if random-float 1 < severe-chance [set severe? true]
  ]

  set total-cases (total-cases + 1)
  (ifelse
    task = "workplace" [set infect-count-work (infect-count-work + 1)]
    task = "groceries" [set infect-count-grocery (infect-count-grocery + 1)]
    task = "commute" [set infect-count-commute (infect-count-commute + 1)]
    task = "hospital" [set infect-count-hospital (infect-count-hospital + 1)]
    task = "leisure" [set infect-count-leisure (infect-count-leisure + 1)]
    [set infect-count-else (infect-count-else + 1)]
  )

  set recovery-time random-normal recovery distribution
  set times-infected (times-infected + 1)
  if times-infected > 1 [set reinfections reinfections + 1]
end

to vax-priority
  ifelse vax-count < vax-goal [
    (ifelse
      vax-group = 1 [ask n-of vax-per-day persons with [healthcare-worker? = true] [vaccinate]]
      vax-group = 2 [ask n-of vax-per-day persons with [senior? = true] [vaccinate]]
      vax-group = 3 [ask n-of vax-per-day persons with [comorbidity? = true] [vaccinate]]
      vax-group = 4 [ask n-of vax-per-day persons with [essential-worker? = true] [vaccinate]]
      vax-group = 5 [ask n-of vax-per-day persons [vaccinate]]
      )
  ][
    set vax-group (vax-group + 1)
    set vax-goal (ifelse-value
      vax-group = 2 [vax-goal + senior-count]
      vax-group = 3 [vax-goal + comorbidity-count]
      vax-group = 4 [vax-goal + count persons with [essential-worker? = true and comorbidity? = false]]
      vax-group = 5 [total-population]
      )
  ]
end ;added by AIC

to vaccinate
  if vaccinated? = false [
    if (times-infected > 0 and recovered-time > 29280) or times-infected = 0 [ ;29280 is the number of ticks for 61 days
      set vaccinated? true
      (ifelse
        vax-type = "mRNA" [set vax-efficacy 0.85]
        vax-type = "Viral-Vector" [set vax-efficacy 0.7]
        vax-type = "Inactivated" [set vax-efficacy 0.42]
        )
      set relative-risk (relative-risk * (1 - vax-efficacy)) ;modifies relative risk based on vax efficacy
      set color blue
      set vaccinations (vaccinations + 1)
    ]
  ]
  set vax-count (vax-count + 1)
end ;added by AIC

to set-relative-death-chance
  ask persons[
    set relative-death-chance 0.01
  ]
  ask persons with [senior? = True][
    set relative-death-chance 0.0377
  ]
  ask persons with [comorbidity? = True][
    set relative-death-chance 0.06
  ]
  ask persons with [vaccinated? = True][
    set relative-death-chance 0
  ] ;added by AIC
end

to recover
  ask persons with [infected? = true][
    ;infected people recover after some number of days drawn from a normal distribution
    if infectious-time >= recovery-time [
      if severe? = true [
        if random-float 1 < (relative-death-chance * 1.05) [die] ;more likely to die if severe
      ]
      if severe? = false and asymptomatic? = false [
        if random-float 1 < relative-death-chance [die]
      ]
      set recoveries recoveries + 1
      set infected? false
      set asymptomatic? false
      set severe? false
      set relative-susceptibility (relative-susceptibility / 5) ;Everytime they get and recover, only 20% to get sick again ;added by AIC
      set relative-risk (relative-risk * relative-susceptibility) ;modifies relative risk based on resistance ;added by AIC
      ;if mask? = false and faceshield? = false [set color green]
      ;if mask? = true and faceshield? = false [set shape "maskman" set color green]
      ;if mask? = true and faceshield? = true [set shape "shieldman" set color green]
      ifelse vaccinated? = true [set color blue][set color green] ;added by AIC
      set infectious-time 0
      set recovered-time 0
    ]
  ]
end

to setup-patches
  ask patches[
    setup-grocery-patch
    setup-hospital-patch
    setup-workplace-patch
    setup-commute-patch
    setup-leisure-patch
    recolor-patch
  ]
end

to setup-grocery-patch
  set grocery-patch? (distancexy (-(max-pxcor / 2)) (-(max-pycor / 2))) < grocery-radius
end

to setup-hospital-patch
  set hospital-patch? (distancexy (max-pxcor / 2) (max-pycor / 2)) < healthcare-radius
end

to setup-commute-patch
  set commute-patch? (distancexy 0 0) < commute-radius
end

to setup-workplace-patch
  set workplace-patch? (distancexy (-(max-pxcor / 2)) ((max-pycor / 2))) < workplace-radius
end

to setup-leisure-patch
  set leisure-patch? (distancexy (max-pxcor / 2) (-(max-pycor / 2))) < leisure-radius
end

to recolor-patch
  if hospital-patch? = true
  [set pcolor white]
  if grocery-patch? = true
  [set pcolor violet]
  if commute-patch? = true
  [set pcolor cyan]
  if workplace-patch? = true
  [set pcolor gray]
  if leisure-patch? = true
  [set pcolor magenta]
end

;to random-move
  ;ask persons with [social-distancing? = false and task != "stayhome"]
  ;ask persons with [infected? = false and task != "stayhome"]
  ;ask persons with [task != "stayhome"] [
    ;right random 360
    ;forward speed
  ;]
;end

;to assign-tasks ;not used
  ;if senior? = true [
    ;ifelse random 20 < 19[set task1 "stayhome" set task1t 160] [set task1 "commute" set task1t random-normal 20 5]
    ;ifelse random 20 < 19[set task2 "stayhome" set task2t 160] [set task2 "commute" set task2t random-normal 20 5]
    ;ifelse random 20 < 19[set task3 "stayhome" set task3t 160] [set task3 "commute" set task3t random-normal 20 5]
  ;]
  ;if ordinary-citizen? = true and comorbidity? = false and senior? = false [
    ;let choice random 10
    ;set task1(ifelse-value
    ;choice = 0 ["stayhome"]
    ;choice = 1 ["stayhome"]
    ;choice = 2 ["stayhome"]
    ;choice = 3 ["stayhome"]
    ;choice = 4 ["stayhome"]
    ;choice = 5 ["commute"]
    ;choice = 6 ["commute"]
    ;choice = 7 ["workplace"]
    ;choice = 8 ["workplace"]
    ;choice = 9 ["groceries"]
    ;)
    ;set task1t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [160]
    ;choice = 2 [160]
    ;choice = 3 [160]
    ;choice = 4 [160]
    ;choice = 5 [random-normal 20 5]
    ;choice = 6 [random-normal 20 5]
    ;choice = 7 [160]
    ;choice = 8 [160]
    ;choice = 9 [random-normal 20 5]
    ;)
    ;set choice random 10
    ;set task2(ifelse-value
    ;choice = 0 ["stayhome"]
    ;choice = 1 ["stayhome"]
    ;choice = 2 ["stayhome"]
    ;choice = 3 ["stayhome"]
    ;choice = 4 ["stayhome"]
    ;choice = 5 ["commute"]
    ;choice = 6 ["commute"]
    ;choice = 7 ["workplace"]
    ;choice = 8 ["workplace"]
    ;choice = 9 ["groceries"]
    ;)
    ;set task2t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [160]
    ;choice = 2 [160]
    ;choice = 3 [160]
    ;choice = 4 [160]
    ;choice = 5 [random-normal 20 5]
    ;choice = 6 [random-normal 20 5]
    ;choice = 7 [160]
    ;choice = 8 [160]
    ;choice = 9 [random-normal 20 5]
    ;)
    ;set choice random 10
    ;set task3(ifelse-value
    ;choice = 0 ["stayhome"]
    ;choice = 1 ["stayhome"]
    ;choice = 2 ["stayhome"]
    ;choice = 3 ["stayhome"]
    ;choice = 4 ["stayhome"]
    ;choice = 5 ["commute"]
    ;choice = 6 ["commute"]
    ;choice = 7 ["workplace"]
    ;choice = 8 ["workplace"]
    ;choice = 9 ["groceries"]
    ;)
    ;set task3t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [160]
    ;choice = 2 [160]
    ;choice = 3 [160]
    ;choice = 4 [160]
    ;choice = 5 [random-normal 20 5]
    ;choice = 6 [random-normal 20 5]
    ;choice = 7 [160]
    ;choice = 8 [160]
    ;choice = 9 [random-normal 20 5]
    ;)
  ;]
  ;if ordinary-citizen? = true and comorbidity? = true[
    ;let choice random 10
    ;set task1(ifelse-value
    ;choice = 0 ["stayhome"]
    ;choice = 1 ["stayhome"]
    ;choice = 2 ["stayhome"]
    ;choice = 3 ["stayhome"]
    ;choice = 4 ["stayhome"]
    ;choice = 5 ["commute"]
    ;choice = 6 ["commute"]
    ;choice = 7 ["hospital"]
    ;choice = 8 ["workplace"]
    ;choice = 9 ["groceries"]
    ;)
    ;set task1t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [160]
    ;choice = 2 [160]
    ;choice = 3 [160]
    ;choice = 4 [160]
    ;choice = 5 [random-normal 20 5]
    ;choice = 6 [random-normal 20 5]
    ;choice = 7 [random-normal 30 5]
    ;choice = 8 [160]
    ;choice = 9 [random-normal 20 5]
    ;)
    ;set choice random 10
    ;set task2(ifelse-value
    ;choice = 0 ["stayhome"]
    ;choice = 1 ["stayhome"]
    ;choice = 2 ["stayhome"]
    ;choice = 3 ["stayhome"]
    ;choice = 4 ["stayhome"]
    ;choice = 5 ["commute"]
    ;choice = 6 ["commute"]
    ;choice = 7 ["hospital"]
    ;choice = 8 ["workplace"]
    ;choice = 9 ["groceries"]
    ;)
    ;set task2t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [160]
    ;choice = 2 [160]
    ;choice = 3 [160]
    ;choice = 4 [160]
    ;choice = 5 [random-normal 20 5]
    ;choice = 6 [random-normal 20 5]
    ;choice = 7 [random-normal 30 5]
    ;choice = 8 [160]
    ;choice = 9 [random-normal 20 5]
    ;)
    ;set choice random 10
    ;set task3(ifelse-value
    ;choice = 0 ["stayhome"]
    ;choice = 1 ["stayhome"]
    ;choice = 2 ["stayhome"]
    ;choice = 3 ["stayhome"]
    ;choice = 4 ["stayhome"]
    ;choice = 5 ["commute"]
    ;choice = 6 ["commute"]
    ;choice = 7 ["hospital"]
    ;choice = 8 ["workplace"]
    ;choice = 9 ["groceries"]
    ;)
    ;set task3t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [160]
    ;choice = 2 [160]
    ;choice = 3 [160]
    ;choice = 4 [160]
    ;choice = 5 [random-normal 20 5]
    ;choice = 6 [random-normal 20 5]
    ;choice = 7 [random-normal 30 5]
    ;choice = 8 [160]
    ;choice = 9 [random-normal 20 5]
    ;)
  ;]
  ;if essential-worker? = true and comorbidity? = false [
   ;let choice random 3
    ;set task1(ifelse-value
    ;choice = 0 ["stayhome"]
    ;choice = 1 ["commute"]
    ;choice = 2 ["groceries"]
    ;)
    ;set task1t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [random-normal 20 5]
    ;choice = 2 [160]
    ;)
    ;set choice random 3
    ;set task2(ifelse-value
    ;choice = 0 ["stayhome"]
    ;choice = 1 ["commute"]
    ;choice = 2 ["groceries"]
    ;)
    ;set task2t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [random-normal 20 5]
    ;choice = 2 [160]
    ;)
    ;set choice random 3
    ;set task3(ifelse-value
    ;choice = 0 ["stayhome"]
    ;choice = 1 ["commute"]
    ;choice = 2 ["groceries"]
    ;)
    ;set task3t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [random-normal 20 5]
    ;choice = 2 [160]
    ;)
  ;]
  ;if essential-worker? = true and comorbidity? = true [
   ;let choice random 3
    ;set task1(ifelse-value
    ;choice = 0 ["stayhome"]
    ;choice = 1 ["commute"]
    ;choice = 2 ["groceries"]
    ;)
    ;set task1t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [random-normal 20 5]
    ;choice = 2 [160]
    ;)
    ;set choice random 3
    ;set task2(ifelse-value
    ;choice = 0 ["stayhome"]
    ;choice = 1 ["commute"]
    ;choice = 2 ["groceries"]
    ;)
    ;set task2t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [random-normal 20 5]
    ;choice = 2 [160]
    ;)
    ;set choice random 3
    ;set task3(ifelse-value
    ;choice = 0 ["stayhome"]
    ;choice = 1 ["commute"]
    ;choice = 2 ["groceries"]
    ;)
    ;set task3t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [random-normal 20 5]
    ;choice = 2 [160]
    ;)
  ;]
  ;if healthcare-worker? = true[
    ;let choice random 10
    ;set task1(ifelse-value
    ;choice = 0 ["hospital"]
    ;choice = 1 ["hospital"]
    ;choice = 2 ["hospital"]
    ;choice = 3 ["hospital"]
    ;choice = 4 ["hospital"]
    ;choice = 5 ["hospital"]
    ;choice = 6 ["commute"]
    ;choice = 7 ["commute"]
    ;choice = 8 ["stayhome"]
    ;choice = 9 ["groceries"]
    ;)
    ;set task1t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [160]
    ;choice = 2 [160]
    ;choice = 3 [160]
    ;choice = 4 [160]
    ;choice = 5 [160]
    ;choice = 6 [random-normal 20 5]
    ;choice = 7 [random-normal 20 5]
    ;choice = 8 [160]
    ;choice = 9 [random-normal 20 5]
    ;)
    ;set choice random 10
    ;set task2(ifelse-value
    ;choice = 0 ["hospital"]
    ;choice = 1 ["hospital"]
    ;choice = 2 ["hospital"]
    ;choice = 3 ["hospital"]
    ;choice = 4 ["hospital"]
    ;choice = 5 ["hospital"]
    ;choice = 6 ["commute"]
    ;choice = 7 ["commute"]
    ;choice = 8 ["stayhome"]
    ;choice = 9 ["groceries"]
    ;)
    ;set task2t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [160]
    ;choice = 2 [160]
    ;choice = 3 [160]
    ;choice = 4 [160]
    ;choice = 5 [160]
    ;choice = 6 [random-normal 20 5]
    ;choice = 7 [random-normal 20 5]
    ;choice = 8 [160]
    ;choice = 9 [random-normal 20 5]
    ;)
    ;set choice random 10
    ;set task3(ifelse-value
    ;choice = 0 ["hospital"]
    ;choice = 1 ["hospital"]
    ;choice = 2 ["hospital"]
    ;choice = 3 ["hospital"]
    ;choice = 4 ["hospital"]
    ;choice = 5 ["hospital"]
    ;choice = 6 ["commute"]
    ;choice = 7 ["commute"]
    ;choice = 8 ["stayhome"]
    ;choice = 9 ["groceries"]
    ;)
    ;set task3t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [160]
    ;choice = 2 [160]
    ;choice = 3 [160]
    ;choice = 4 [160]
    ;choice = 5 [160]
    ;choice = 6 [random-normal 20 5]
    ;choice = 7 [random-normal 20 5]
    ;choice = 8 [160]
    ;choice = 9 [random-normal 20 5]
    ;)
  ;]
  ;if severe? = true[
    ;let choice random 10
    ;set task1(ifelse-value
    ;choice = 0 ["hospital"]
    ;choice = 1 ["hospital"]
    ;choice = 2 ["hospital"]
    ;choice = 3 ["hospital"]
    ;choice = 4 ["hospital"]
    ;choice = 5 ["hospital"]
    ;choice = 6 ["hospital"]
    ;choice = 7 ["hospital"]
    ;choice = 8 ["hospital"]
    ;choice = 9 ["stayhome"]
    ;)
    ;set task1t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [160]
    ;choice = 2 [160]
    ;choice = 3 [160]
    ;choice = 4 [160]
    ;choice = 5 [160]
    ;choice = 6 [160]
    ;choice = 7 [160]
    ;choice = 8 [160]
    ;choice = 9 [160]
    ;)
    ;set choice random 10
    ;set task2(ifelse-value
    ;choice = 0 ["hospital"]
    ;choice = 1 ["hospital"]
    ;choice = 2 ["hospital"]
    ;choice = 3 ["hospital"]
    ;choice = 4 ["hospital"]
    ;choice = 5 ["hospital"]
    ;choice = 6 ["hospital"]
    ;choice = 7 ["hospital"]
    ;choice = 8 ["hospital"]
    ;choice = 9 ["stayhome"]
    ;)
    ;set task2t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [160]
    ;choice = 2 [160]
    ;choice = 3 [160]
    ;choice = 4 [160]
    ;choice = 5 [160]
    ;choice = 6 [160]
    ;choice = 7 [160]
    ;choice = 8 [160]
    ;choice = 9 [160]
    ;)
    ;set choice random 10
    ;set task3(ifelse-value
    ;choice = 0 ["hospital"]
    ;choice = 1 ["hospital"]
    ;choice = 2 ["hospital"]
    ;choice = 3 ["hospital"]
    ;choice = 4 ["hospital"]
    ;choice = 5 ["hospital"]
    ;choice = 6 ["hospital"]
    ;choice = 7 ["hospital"]
    ;choice = 8 ["hospital"]
    ;choice = 9 ["stayhome"]
    ;)
    ;set task3t(ifelse-value
    ;choice = 0 [160]
    ;choice = 1 [160]
    ;choice = 2 [160]
    ;choice = 3 [160]
    ;choice = 4 [160]
    ;choice = 5 [160]
    ;choice = 6 [160]
    ;choice = 7 [160]
    ;choice = 8 [160]
    ;choice = 9 [160]
    ;)
  ;]
;end

to commuting
  ask persons with [task = "commute"] [
    ifelse pcolor = cyan [
      set task-time (task-time + 1)
      ask persons with [task = "commute"] [
        right random 360
        forward speed
      ]
    ][
      ask persons with [task = "commute"] [
        let mycommute nearby-commute
        face mycommute
        forward speed
      ]
    ]
    if task-time > taskt [set taskcnt (taskcnt + 1) set task-time 0]
  ]
end

to-report nearby-commute
  report min-one-of commutes [distance myself]
end

to workplacing
  ask persons with [task = "workplace"] [
    ifelse pcolor = gray [
      set task-time (task-time + 1)
      ask persons with [task = "workplace"] [
        right random 360
        forward speed
      ]
    ][
      ask persons with [task = "workplace"] [
        let myworkplace nearby-workplace
        face myworkplace
        forward speed
      ]
    ]
    if task-time > taskt [set taskcnt (taskcnt + 1) set task-time 0]
  ]
end

to-report nearby-workplace
  report min-one-of workplaces [distance myself]
end

to grocerying
  ask persons with [task = "groceries"] [
    ifelse pcolor = violet [
      set task-time (task-time + 1)
      ask persons with [task = "groceries"] [
        right random 360
        forward speed
      ]
    ][
      ask persons with [task = "groceries"] [
        let mygrocery nearby-groceries
        face mygrocery
        forward speed
      ]
    ]
    if task-time > taskt [set taskcnt (taskcnt + 1) set task-time 0]
  ]
end

to-report nearby-groceries
  report min-one-of groceries [distance myself]
end

to leisuring
  ask persons with [task = "leisure"] [
    ifelse pcolor = magenta [
      set task-time (task-time + 1)
      ask persons with [task = "leisure"] [
        right random 360
        forward speed
      ]
    ][
      ask persons with [task = "leisure"] [
        let myleisure nearby-leisure
        face myleisure
        forward speed
      ]
    ]
    if task-time > taskt [set taskcnt (taskcnt + 1) set task-time 0]
  ]
end

to-report nearby-leisure
  report min-one-of leisures [distance myself]
end

to hospitaling
  ask persons with [task = "hospital"] [
    ifelse pcolor = white [
      set task-time (task-time + 1)
      ask persons with [task = "hospital" and infected? = false] [
        right random 360
        forward speed
      ]
    ][
      ask persons with [task = "hospital"] [
        let myhospital nearby-hospitals
        face myhospital
        forward speed
      ]
    ]
    if task-time > taskt [set taskcnt (taskcnt + 1) set task-time 0]
  ]
end

to gohome
  ask persons with [task = "stayhome"] [
    facexy x-home y-home
    forward speed

    if curfew? = false
    [set task-time (task-time + 1)]

    if task-time > taskt [set taskcnt (taskcnt + 1) set task-time 0]
  ]
end

to do-task
 ask persons[
    if taskcnt >= 5 [set taskcnt 4]
    set taskt(ifelse-value
    taskcnt = 1 [task1t]
    taskcnt = 2 [task2t]
    taskcnt = 3 [task3t]
    taskcnt = 4 [320]
    )
  set task(ifelse-value
    taskcnt = 1 [task1]
    taskcnt = 2 [task2]
    taskcnt = 3 [task3]
    taskcnt = 4 ["stayhome"]
    )
  ]
end

to gcq-assign-task
  if senior? = true [
    let choice random 20
    set task1(ifelse-value
    choice  <= 9 ["stayhome"]
    choice <= 15 ["leisure"]
    choice  <= 16 ["commute"]
    choice <= 17 ["hospital"]
    choice <= 19 ["groceries"]
    )
    set task1t(ifelse-value
    choice <= 9 [160]
    choice <= 16 [random-normal 20 5]
    choice <= 17 [random-normal 20 5]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task2(ifelse-value
    choice  <= 9 ["stayhome"]
    choice  <= 16 ["commute"]
    choice <= 17 ["hospital"]
    choice <= 19 ["groceries"]
    )
    set task2t(ifelse-value
    choice <= 9 [160]
    choice <= 16 [random-normal 20 5]
    choice <= 17 [random-normal 20 5]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task3(ifelse-value
    choice  <= 9 ["stayhome"]
    choice  <= 16 ["commute"]
    choice <= 17 ["hospital"]
    choice <= 19 ["groceries"]
    )
    set task3t(ifelse-value
    choice <= 9 [160]
    choice <= 16 [random-normal 20 5]
    choice <= 17 [random-normal 20 5]
    choice <= 19 [random-normal 20 5]
    )
  ]

  if ordinary-citizen? = true and comorbidity? = false and senior? = false [
    let choice random 20
    set task1(ifelse-value
    choice  <= 3 ["stayhome"]
    choice <= 15 ["leisure"]
    choice  <= 9 ["commute"]
    choice <= 17 ["workplace"]
    choice <= 19 ["groceries"]
    )
    set task1t(ifelse-value
    choice <= 3 [160]
    choice <= 9 [random-normal 20 5]
    choice <= 17 [160]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task2(ifelse-value
    choice  <= 3 ["stayhome"]
    choice  <= 9 ["commute"]
    choice <= 17 ["workplace"]
    choice <= 19 ["groceries"]
    )
    set task2t(ifelse-value
    choice <= 3 [160]
    choice <= 9 [random-normal 20 5]
    choice <= 17 [160]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task3(ifelse-value
    choice  <= 3 ["stayhome"]
    choice  <= 9 ["commute"]
    choice <= 17 ["workplace"]
    choice <= 19 ["groceries"]
    )
    set task3t(ifelse-value
    choice <= 3 [160]
    choice <= 9 [random-normal 20 5]
    choice <= 17 [160]
    choice <= 19 [random-normal 20 5]
    )
  ]

  if ordinary-citizen? = true and comorbidity? = true [
    let choice random 20
    set task1(ifelse-value
    choice <= 3 ["stayhome"]
    choice <= 9 ["commute"]
    choice <= 15 ["leisure"]
    choice <= 10 ["hospital"]
    choice <= 17["workplace"]
    choice <= 19 ["groceries"]
    )
    set task1t(ifelse-value
    choice <= 3 [160]
    choice <= 9 [random-normal 20 5]
    choice <= 10 [random-normal 30 5]
    choice <= 17 [160]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task2(ifelse-value
    choice <= 3 ["stayhome"]
    choice <= 9 ["commute"]
    choice <= 10 ["hospital"]
    choice <= 17["workplace"]
    choice <= 19 ["groceries"]
    )
    set task2t(ifelse-value
    choice <= 3 [160]
    choice <= 9 [random-normal 20 5]
    choice <= 10 [random-normal 30 5]
    choice <= 17 [160]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task3(ifelse-value
    choice <= 3 ["stayhome"]
    choice <= 9 ["commute"]
    choice <= 10 ["hospital"]
    choice <= 17["workplace"]
    choice <= 19 ["groceries"]
    )
    set task3t(ifelse-value
    choice <= 3 [160]
    choice <= 9 [random-normal 20 5]
    choice <= 10 [random-normal 30 5]
    choice <= 17 [160]
    choice <= 19 [random-normal 20 5]
    )
  ]

  if essential-worker? = true and comorbidity? = false [
   let choice random 3
    set task1(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task1t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )

    set choice random 3
    set task2(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task2t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )
    set choice random 3
    set task3(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task3t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )
  ]

  if essential-worker? = true and comorbidity? = true [
    let choice random 3
    set task1(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task1t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )

    set choice random 3
    set task2(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task2t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )
    set choice random 3
    set task3(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task3t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )
  ]

  if healthcare-worker? = true [
    let choice random 10
    set task1(ifelse-value
    choice <= 5 ["hospital"]
    choice <= 7 ["commute"]
    choice = 8 ["stayhome"]
    choice = 9 ["groceries"]
    )
    set task1t(ifelse-value
    choice <= 5 [160]
    choice = 6 [random-normal 20 5]
    choice = 7 [random-normal 20 5]
    choice = 8 [160]
    choice = 9 [random-normal 20 5]
    )
    set choice random 10
    set task2(ifelse-value
    choice <= 5 ["hospital"]
    choice = 6 ["commute"]
    choice = 7 ["commute"]
    choice = 8 ["stayhome"]
    choice = 9 ["groceries"]
    )
    set task2t(ifelse-value
    choice <= 5 [160]
    choice = 6 [random-normal 20 5]
    choice = 7 [random-normal 20 5]
    choice = 8 [160]
    choice = 9 [random-normal 20 5]
    )
    set choice random 10
    set task3(ifelse-value
    choice <= 5 ["hospital"]
    choice = 6 ["commute"]
    choice = 7 ["commute"]
    choice = 8 ["stayhome"]
    choice = 9 ["groceries"]
    )
    set task3t(ifelse-value
    choice <= 5 [160]
    choice = 6 [random-normal 20 5]
    choice = 7 [random-normal 20 5]
    choice = 8 [160]
    choice = 9 [random-normal 20 5]
    )
  ]

  if severe? = true [
    ;Pasaway chance
    if random 5 > 1 [
      let choice random 10
      set task1(ifelse-value
        choice <= 8 ["hospital"]
        choice = 9 ["stayhome"]
      )
      set task1t(ifelse-value
        choice <= 9 [160]
      )
      set choice random 10
      set task2(ifelse-value
        choice <= 8 ["hospital"]
        choice = 9 ["stayhome"]
      )
      set task2t(ifelse-value
        choice <= 9 [160]
      )
      set choice random 10
      set task3(ifelse-value
        choice <= 8 ["hospital"]
        choice = 9 ["stayhome"]
      )
      set task3t(ifelse-value
        choice <= 9 [160]
      )
    ]
  ]

  if asymptomatic? = true [
    if random 5 > 1 [
      set task1 "stayhome"
      set task1t 160

      set task2 "stayhome"
      set task2t 160

      set task3 "stayhome"
      set task3t 160
    ]
  ]

  if infected? = true and severe? = false and asymptomatic? = false[
    if random 5 > 1 [
      let choice random 10
      set task1(ifelse-value
        choice <= 8 ["stayhome"]
        choice = 9 ["hospital"]
      )
      set task1t(ifelse-value
        choice <= 9 [160]
      )
      set choice random 10
      set task2(ifelse-value
        choice <= 8 ["stayhome"]
        choice = 9 ["hospital"]
      )
      set task2t(ifelse-value
        choice <= 9 [160]
      )
      set choice random 10
      set task3(ifelse-value
        choice <= 8 ["stayhome"]
        choice = 9 ["hospital"]
      )
      set task3t(ifelse-value
        choice <= 9 [160]
      )
    ]
  ]
end

to mecq-assign-task
  if senior? = true [
    let choice random 20
    set task1(ifelse-value
    choice  <= 14 ["stayhome"]
    choice  <= 16 ["commute"]
    choice <= 17 ["hospital"]
    choice <= 19 ["groceries"]
    )
    set task1t(ifelse-value
    choice <= 14 [160]
    choice <= 16 [random-normal 20 5]
    choice <= 17 [random-normal 20 5]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task2(ifelse-value
    choice  <= 14 ["stayhome"]
    choice  <= 16 ["commute"]
    choice <= 17 ["hospital"]
    choice <= 19 ["groceries"]
    )
    set task2t(ifelse-value
    choice <= 14 [160]
    choice <= 16 [random-normal 20 5]
    choice <= 17 [random-normal 20 5]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task3(ifelse-value
    choice  <= 14 ["stayhome"]
    choice  <= 16 ["commute"]
    choice <= 17 ["hospital"]
    choice <= 19 ["groceries"]
    )
    set task3t(ifelse-value
    choice <= 14 [160]
    choice <= 16 [random-normal 20 5]
    choice <= 17 [random-normal 20 5]
    choice <= 19 [random-normal 20 5]
    )
  ]

  if ordinary-citizen? = true and comorbidity? = false and senior? = false [
    let choice random 20
    set task1(ifelse-value
    choice  <= 9 ["stayhome"]
    choice  <= 13 ["commute"]
    choice <= 17 ["workplace"]
    choice <= 19 ["groceries"]
    )
    set task1t(ifelse-value
    choice <= 9 [160]
    choice <= 13 [random-normal 20 5]
    choice <= 17 [160]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task2(ifelse-value
    choice  <= 9 ["stayhome"]
    choice  <= 13 ["commute"]
    choice <= 17 ["workplace"]
    choice <= 19 ["groceries"]
    )
    set task2t(ifelse-value
    choice <= 9 [160]
    choice <= 13 [random-normal 20 5]
    choice <= 17 [160]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task3(ifelse-value
    choice  <= 9 ["stayhome"]
    choice  <= 13 ["commute"]
    choice <= 17 ["workplace"]
    choice <= 19 ["groceries"]
    )
    set task3t(ifelse-value
    choice <= 9 [160]
    choice <= 13 [random-normal 20 5]
    choice <= 17 [160]
    choice <= 19 [random-normal 20 5]
    )
  ]

 if ordinary-citizen? = true and comorbidity? = true [
    let choice random 20
    set task1(ifelse-value
    choice <= 10 ["stayhome"]
    choice <= 12 ["commute"]
    choice <= 13 ["hospital"]
    choice <= 17["workplace"]
    choice <= 19 ["groceries"]
    )
    set task1t(ifelse-value
    choice <= 10 [160]
    choice <= 12 [random-normal 20 5]
    choice <= 13 [random-normal 30 5]
    choice <= 17 [160]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task2(ifelse-value
    choice <= 10 ["stayhome"]
    choice <= 12 ["commute"]
    choice <= 13 ["hospital"]
    choice <= 17["workplace"]
    choice <= 19 ["groceries"]
    )
    set task2t(ifelse-value
    choice <= 10 [160]
    choice <= 12 [random-normal 20 5]
    choice <= 13 [random-normal 30 5]
    choice <= 17 [160]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task3(ifelse-value
    choice <= 10 ["stayhome"]
    choice <= 12 ["commute"]
    choice <= 13 ["hospital"]
    choice <= 17["workplace"]
    choice <= 19 ["groceries"]
    )
    set task3t(ifelse-value
    choice <= 10 [160]
    choice <= 12 [random-normal 20 5]
    choice <= 13 [random-normal 30 5]
    choice <= 17 [160]
    choice <= 19 [random-normal 20 5]
    )
  ]

  if essential-worker? = true and comorbidity? = false [
    let choice random 3
    set task1(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task1t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )

    set choice random 3
    set task2(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task2t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )
    set choice random 3
    set task3(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task3t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )
  ]

  if essential-worker? = true and comorbidity? = true [
   let choice random 3
    set task1(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task1t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )

    set choice random 3
    set task2(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task2t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )
    set choice random 3
    set task3(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task3t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )
  ]

  if healthcare-worker? = true [
    let choice random 10
    set task1(ifelse-value
    choice <= 5 ["hospital"]
    choice <= 7 ["commute"]
    choice = 8 ["stayhome"]
    choice = 9 ["groceries"]
    )
    set task1t(ifelse-value
    choice <= 5 [160]
    choice = 6 [random-normal 20 5]
    choice = 7 [random-normal 20 5]
    choice = 8 [160]
    choice = 9 [random-normal 20 5]
    )
    set choice random 10
    set task2(ifelse-value
    choice <= 5 ["hospital"]
    choice = 6 ["commute"]
    choice = 7 ["commute"]
    choice = 8 ["stayhome"]
    choice = 9 ["groceries"]
    )
    set task2t(ifelse-value
    choice <= 5 [160]
    choice = 6 [random-normal 20 5]
    choice = 7 [random-normal 20 5]
    choice = 8 [160]
    choice = 9 [random-normal 20 5]
    )
    set choice random 10
    set task3(ifelse-value
    choice <= 5 ["hospital"]
    choice = 6 ["commute"]
    choice = 7 ["commute"]
    choice = 8 ["stayhome"]
    choice = 9 ["groceries"]
    )
    set task3t(ifelse-value
    choice <= 5 [160]
    choice = 6 [random-normal 20 5]
    choice = 7 [random-normal 20 5]
    choice = 8 [160]
    choice = 9 [random-normal 20 5]
    )
  ]

  if severe? = true [
    if random 5 > 1 [
      let choice random 10
      set task1(ifelse-value
        choice <= 8 ["hospital"]
        choice = 9 ["stayhome"]
      )
      set task1t(ifelse-value
        choice <= 9 [160]
      )
      set choice random 10
      set task2(ifelse-value
        choice <= 8 ["hospital"]
        choice = 9 ["stayhome"]
      )
      set task2t(ifelse-value
        choice <= 9 [160]
      )
      set choice random 10
      set task3(ifelse-value
        choice <= 8 ["hospital"]
        choice = 9 ["stayhome"]
      )
      set task3t(ifelse-value
        choice <= 9 [160]
      )
    ]
  ]

  if asymptomatic? = true [
    if random 5 > 1 [
      set task1 "stayhome"
      set task1t 160

      set task2 "stayhome"
      set task2t 160

      set task3 "stayhome"
      set task3t 160
    ]
  ]

  if infected? = true and severe? = false and asymptomatic? = false[
    if random 5 > 1 [
      let choice random 10
      set task1(ifelse-value
        choice <= 8 ["stayhome"]
        choice = 9 ["hospital"]
      )
      set task1t(ifelse-value
        choice <= 9 [160]
      )
      set choice random 10
      set task2(ifelse-value
        choice <= 8 ["stayhome"]
        choice = 9 ["hospital"]
      )
      set task2t(ifelse-value
        choice <= 9 [160]
      )
      set choice random 10
      set task3(ifelse-value
        choice <= 8 ["stayhome"]
        choice = 9 ["hospital"]
      )
      set task3t(ifelse-value
        choice <= 9 [160]
      )
    ]
  ]
end

to ecq-assign-task
  if senior? = true [
    let choice random 20
    set task1(ifelse-value
    choice  <= 17 ["stayhome"]
    choice <= 18 ["hospital"]
    choice <= 19 ["groceries"]
    )
    set task1t(ifelse-value
    choice <= 17 [160]
    choice <= 18 [random-normal 20 5]
    choice = 19 [random-normal 20 5]
    )
    set choice random 20
    set task2(ifelse-value
    choice  <= 17 ["stayhome"]
    choice <= 18 ["hospital"]
    choice <= 19 ["groceries"]
    )
    set task2t(ifelse-value
    choice <= 17 [160]
    choice <= 18 [random-normal 20 5]
    choice = 19 [random-normal 20 5]
    )
    set choice random 20
    set task3(ifelse-value
    choice  <= 17 ["stayhome"]
    choice <= 18 ["hospital"]
    choice <= 19 ["groceries"]
    )
    set task3t(ifelse-value
    choice <= 17 [160]
    choice <= 18 [random-normal 20 5]
    choice = 19 [random-normal 20 5]
    )
  ]

  if ordinary-citizen? = true and comorbidity? = false and senior? = false [
    let choice random 20
    set task1(ifelse-value
    choice  <= 17 ["stayhome"]
    choice <= 19 ["groceries"]
    )
    set task1t(ifelse-value
    choice <= 17 [160]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task2(ifelse-value
    choice  <= 17 ["stayhome"]
    choice <= 19 ["groceries"]
    )
    set task2t(ifelse-value
    choice <= 17 [160]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task3(ifelse-value
    choice  <= 17 ["stayhome"]
    choice <= 19 ["groceries"]
    )
    set task3t(ifelse-value
    choice <= 17 [160]
    choice <= 19 [random-normal 20 5]
    )
  ]

  if ordinary-citizen? = true and comorbidity? = true [
    let choice random 20
    set task1(ifelse-value
    choice <= 16 ["stayhome"]
    choice <= 17 ["hospital"]
    choice <= 19 ["groceries"]
    )
    set task1t(ifelse-value
    choice <= 16 [160]
    choice <= 17 [random-normal 30 5]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task2(ifelse-value
    choice <= 16 ["stayhome"]
    choice <= 17 ["hospital"]
    choice <= 19 ["groceries"]
    )
    set task2t(ifelse-value
    choice <= 16 [160]
    choice <= 17 [random-normal 30 5]
    choice <= 19 [random-normal 20 5]
    )
    set choice random 20
    set task3(ifelse-value
    choice <= 16 ["stayhome"]
    choice <= 17 ["hospital"]
    choice <= 19 ["groceries"]
    )
    set task3t(ifelse-value
    choice <= 16 [160]
    choice <= 17 [random-normal 30 5]
    choice <= 19 [random-normal 20 5]
    )
  ]

  if essential-worker? = true and comorbidity? = false [
    let choice random 3
    set task1(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task1t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )

    set choice random 3
    set task2(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task2t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )
    set choice random 3
    set task3(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task3t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )
  ]

  if essential-worker? = true and comorbidity? = true [
    let choice random 3
    set task1(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task1t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )

    set choice random 3
    set task2(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task2t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )
    set choice random 3
    set task3(ifelse-value
    choice = 0 ["stayhome"]
    choice = 1 ["commute"]
    choice = 2 ["groceries"]

    )
    set task3t(ifelse-value
    choice = 0 [160]
    choice = 1 [random-normal 20 5]
    choice = 2 [160]
    )
  ]

  if healthcare-worker? = true [
    let choice random 10
    set task1(ifelse-value
    choice <= 5 ["hospital"]
    choice <= 7 ["commute"]
    choice = 8 ["stayhome"]
    choice = 9 ["groceries"]
    )
    set task1t(ifelse-value
    choice <= 5 [160]
    choice = 6 [random-normal 20 5]
    choice = 7 [random-normal 20 5]
    choice = 8 [160]
    choice = 9 [random-normal 20 5]
    )
    set choice random 10
    set task2(ifelse-value
    choice <= 5 ["hospital"]
    choice = 6 ["commute"]
    choice = 7 ["commute"]
    choice = 8 ["stayhome"]
    choice = 9 ["groceries"]
    )
    set task2t(ifelse-value
    choice <= 5 [160]
    choice = 6 [random-normal 20 5]
    choice = 7 [random-normal 20 5]
    choice = 8 [160]
    choice = 9 [random-normal 20 5]
    )
    set choice random 10
    set task3(ifelse-value
    choice <= 5 ["hospital"]
    choice = 6 ["commute"]
    choice = 7 ["commute"]
    choice = 8 ["stayhome"]
    choice = 9 ["groceries"]
    )
    set task3t(ifelse-value
    choice <= 5 [160]
    choice = 6 [random-normal 20 5]
    choice = 7 [random-normal 20 5]
    choice = 8 [160]
    choice = 9 [random-normal 20 5]
    )
  ]

  if severe? = true [
    if random 5 > 1 [
      let choice random 10
      set task1(ifelse-value
        choice <= 8 ["hospital"]
        choice = 9 ["stayhome"]
      )
      set task1t(ifelse-value
        choice <= 9 [160]
      )
      set choice random 10
      set task2(ifelse-value
        choice <= 8 ["hospital"]
        choice = 9 ["stayhome"]
      )
      set task2t(ifelse-value
        choice <= 9 [160]
      )
      set choice random 10
      set task3(ifelse-value
        choice <= 8 ["hospital"]
        choice = 9 ["stayhome"]
      )
      set task3t(ifelse-value
        choice <= 9 [160]
      )
    ]
  ]

  if asymptomatic? = true [
    if random 5 > 1 [
      set task1 "stayhome"
      set task1t 160

      set task2 "stayhome"
      set task2t 160

      set task3 "stayhome"
      set task3t 160
    ]
  ]

  if infected? = true and severe? = false and asymptomatic? = false[
    if random 5 > 1 [
      let choice random 10
      set task1(ifelse-value
        choice <= 8 ["stayhome"]
        choice = 9 ["hospital"]
      )
      set task1t(ifelse-value
        choice <= 9 [160]
      )
      set choice random 10
      set task2(ifelse-value
        choice <= 8 ["stayhome"]
        choice = 9 ["hospital"]
      )
      set task2t(ifelse-value
        choice <= 9 [160]
      )
      set choice random 10
      set task3(ifelse-value
        choice <= 8 ["stayhome"]
        choice = 9 ["hospital"]
      )
      set task3t(ifelse-value
        choice <= 9 [160]
      )
    ]
  ]
end

to setup-patch-area
  set grocery-radius ( (sqrt (grocery-area / pi)) / 1.5)
  set healthcare-radius ( (sqrt (healthcare-area / pi)) / 1.5)
  set commute-radius ( (sqrt (commute-area / pi)) / 1.5)
  set workplace-radius ( (sqrt (workplace-area / pi)) / 1.5)
  set leisure-radius ( (sqrt (leisure-area / pi)) / 1.5)
end

to count-deaths
  set deaths (total-population - count persons)
  set senior-deaths (senior-count - count persons with [senior? = true])
  set comorbid-deaths (comorbidity-count - count persons with [comorbidity? = true])
end

to set-exposed
  ask persons with [infected? = false][
    if any? persons with [infected? = true] in-radius 1.33 [set exposed-time (exposed-time + 1)]
    ifelse exposed-time >= 5 [set exposed? true set color yellow][set exposed? false ifelse vaccinated? = true [set color blue][set color green]]
    if not any? persons with [infected? = true] in-radius 1 [if exposed-time > 0 [set exposed-time (exposed-time - 1)]]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
198
76
911
790
-1
-1
5.0
1
10
1
1
1
0
0
0
1
-70
70
-70
70
0
0
1
ticks
3000.0

BUTTON
30
25
96
58
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
105
25
168
58
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
940
245
1515
460
Spread of Disease
time
number of infectives
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -16777216 true "" "plot count persons with [infected? = true]"

BUTTON
175
25
237
58
clear
clear-all
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
30
385
180
445
base-infection-risk
0.006
1
0
Number

INPUTBOX
1388
26
1538
86
mask-wear-percent
90.0
1
0
Number

INPUTBOX
1388
86
1538
146
mask-wear-faceshield-percent
80.0
1
0
Number

INPUTBOX
30
225
180
285
maximum-days
0.0
1
0
Number

CHOOSER
30
180
180
225
tick-represents
tick-represents
"3 Minutes" "1 Day" "15 Minutes"
0

INPUTBOX
938
86
1090
146
starting-infected
50.0
1
0
Number

INPUTBOX
938
26
1090
86
total-population
938.0
1
0
Number

INPUTBOX
1238
26
1390
86
healthcare-worker-count
110.0
1
0
Number

INPUTBOX
1238
86
1390
146
essential-worker-count
220.0
1
0
Number

INPUTBOX
1088
26
1240
86
comorbidity-count
40.0
1
0
Number

INPUTBOX
1088
86
1240
146
senior-count
40.0
1
0
Number

MONITOR
938
146
995
191
NIL
hour
17
1
11

INPUTBOX
30
120
180
180
curfew-hours
0.0
1
0
Number

MONITOR
993
146
1050
191
NIL
curfew?
17
1
11

PLOT
940
460
1515
645
Daily Chart
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Active Cases" 1.0 0 -2674135 true "" "plotxy days (count persons with [infected? = true])"
"Recoveries" 1.0 0 -5825686 true "" "plotxy days recoveries"
"Deaths" 1.0 0 -16777216 true "" "plotxy days deaths"
"Exposed" 1.0 0 -4079321 true "" "plotxy days (count persons with [color = yellow])"

MONITOR
1048
146
1105
191
NIL
days
17
1
11

PLOT
1515
460
2091
645
Daily total cases
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy days total-cases"

PLOT
940
645
1515
800
Daily Deaths
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Total Deaths" 1.0 0 -16777216 true "" "plotxy days deaths"
"Senior Deaths" 1.0 0 -8630108 true "" "plotxy deaths senior-deaths"
"Comorbid Death" 1.0 0 -6459832 true "" "plotxy days comorbid-deaths"

PLOT
1515
645
2090
800
Daily total recoveries
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy days recoveries"

CHOOSER
30
75
180
120
quarantine-level
quarantine-level
"GCQ" "MECQ" "ECQ"
0

MONITOR
1420
200
1477
245
NIL
deaths
17
1
11

INPUTBOX
30
500
180
560
healthcare-area
1500.0
1
0
Number

INPUTBOX
30
560
180
620
grocery-area
3000.0
1
0
Number

INPUTBOX
30
620
180
680
commute-area
3000.0
1
0
Number

INPUTBOX
30
680
180
740
workplace-area
4500.0
1
0
Number

INPUTBOX
30
740
180
800
leisure-area
4500.0
1
0
Number

TEXTBOX
35
475
185
493
Area (sq. m)
11
0.0
1

MONITOR
1144
200
1246
245
Persons infected
count persons with [infected? = true]
17
1
11

TEXTBOX
45
825
235
1010
Grey: Workplace\nViolet: Grocery\nWhite: Hospital\nCyan: Commute\nRed persons: Infected population\nOrange persons: Asymptomatic population\nYellow persons: Exposed population\nGreen persons: Susceptible population\nBlue persons: Vaccinated population
11
0.0
1

MONITOR
1320
200
1420
245
Reinfected agents
count persons with [times-infected > 1]
17
1
11

MONITOR
1244
200
1321
245
NIL
reinfections
17
1
11

INPUTBOX
1538
26
1691
86
starting-vax-count
500.0
1
0
Number

MONITOR
1474
200
1557
245
vaccinations
vaccinations
17
1
11

INPUTBOX
1538
86
1691
146
vax-per-day
1.0
1
0
Number

MONITOR
939
200
1146
245
Persons exposed (not sick)
count persons with [color = yellow]
17
1
11

PLOT
1515
245
2091
460
Contact Tracing
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Other" 1.0 0 -16777216 true "" "plotxy days infect-count-else"
"Workplace" 1.0 0 -7500403 true "" "plotxy days infect-count-work"
"Grocery" 1.0 0 -8630108 true "" "plotxy days infect-count-grocery"
"Commute" 1.0 0 -11221820 true "" "plotxy days infect-count-commute"
"Hospital" 1.0 0 -2674135 true "" "plotxy days infect-count-hospital"
"Leisure" 1.0 0 -5825686 true "" "plotxy days infect-count-leisure"

MONITOR
1620
200
1682
245
NIL
vax-goal
17
1
11

MONITOR
1555
200
1622
245
NIL
vax-count
17
1
11

CHOOSER
30
285
180
330
vax-type
vax-type
"Inactivated" "Viral-Vector" "mRNA"
2

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

maskman
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Rectangle -7500403 false true 30 75 30 75
Circle -7500403 false true 116 26 67
Polygon -1184463 true false 105 60 150 135 195 60 105 60 105 60

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

shieldman
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Rectangle -7500403 false true 30 75 30 75
Circle -7500403 false true 116 26 67
Polygon -1184463 true false 105 60 150 135 195 60 105 60 105 60
Rectangle -1 true false 105 15 195 60

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
