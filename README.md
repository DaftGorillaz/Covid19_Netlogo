# Netlogo COVID-19 Simulations

This study aims to analyze the COVID-19 pandemic response of the Philippines using NetLogo Simulation, specifically to see how the various types of vaccines available and community quarantines being implemented contribute to the alleviation of the multiple variants of the SARS-CoV-2, with special attention to the delta variant



## Authors

- Ateneo Innovation Center
- Lorenzo Paolo C. Galvez
- Dominic Lance B. Salmingo

## Objectives
- [ ] Create a baseline wherein, non-pharmaceutical response and MHS are used in community quarantines against the Delta and non-Delta variants.
- [ ] Simulate the pandemic with the addition of the multiple pharmaceutical responses one at a time. Changing from on type of vaccine to another
- [ ] Compare the results of pharmaceutical response against the non-pharmaceutical response against the pandemic
- [ ] Compare the simulation results with real world data.
- [ ] Analyze the simulation results to determine the necessity of community quarantines
- [ ] Determine, through the simulation, when the pandemic will end.

## Vaccine Types
| Inactivated       | Viral Vector                | mRNA            |
| :---:             |    :----:                   |    :---:        |
| Sinovac-CoronaVac | Oxford-AstraZeneca          | Moderna         |
|                   | Johnson & Johnson's Janssen | Pfizer-BioNTech |
|                   | Sputnik V                   |                 |

## Efficacies
| Vaccine Type  | Infection  | Disease  |
| :---:         | :----:     |  :---:   |
| Inactivated   | 39.50%     | 44.75%   |
| Viral Vector  | 60.83%     | 78.58%   |
| mRNA          | 81.13%     | 90.63%   |

## Setup
![setup](https://user-images.githubusercontent.com/55699420/157391268-a902cda7-e43b-49e7-b2f1-10c17a2c6be7.gif)

700x700 Area
### Legend
- Patches
  - Grey:     Workplace
  - Violet:   Grocery
  - White:    Hospital
  - Cyan:     Commute
  - Magenta:  Leisure
- Persons
  - Red:    INFECTED
  - Orange: ASYMPTOMATIC
  - Yellow: EXPOSED
  - Green:  SUSCEPTIBLE
  - Blue:   VACCINATED

## Simulation Table
| **Scenario Title**  | **Variant** | **Alert Level** | **Vaccine** |
| :---:               | :---:       | :---:           | :---:       |
| D-1-NULL            | Delta       | 1   | No Vaccine  |
| D-1-INAC            | Delta       | 1   | Inactivated |
| D-1-VIRA            | Delta       | 1   | Viral Vector |
| D-1-MRNA            | Delta       | 1   | mRNA  |
| D-23-NULL           | Delta       | 2,3 | No Vaccine  |
| D-23-INAC           | Delta       | 2,3 | Inactivated |
| D-23-VIRA           | Delta       | 2,3 | Viral Vector  |
| D-23-MRNA           | Delta       | 2,3 | mRNA      |
| D-45-NULL           | Delta       | 4,5 | No Vaccine  |
| D-45-INAC           | Delta       | 4,5 | Inactivated |
| D-45-VIRA           | Delta       | 4,5 | Viral Vector  |
| D-45-MRNA           | Delta       | 4,5 | mRNA  |
| ND-1-NULL           | Non-Delta       | 1   | No Vaccine  |
| ND-1-INAC           | Non-Delta | 1 | Inactivated |
| ND-1-VIRA | Non-Delta | 1 | Viral Vector |
| ND-1-MRNA | Non-Delta | 1 | mRNA |
| ND-23-NULL | Non-Delta | 2,3 | No Vaccine |
| ND-23-INAC | Non-Delta | 2,3 | Inactivated |
| ND-23-VIRA | Non-Delta | 2,3 | Viral Vector |
| ND-23-MRNA | Non-Delta | 2,3 | mRNA |
| ND-45-NULL | Non-Delta | 4,5 | No Vaccine |
| ND-45-INAC | Non-Delta | 4,5 | Inactivated |
| ND-45-VIRA | Non-Delta | 4,5 | Viral Vector |
| ND-45-MRNA | Non-Delta | 4,5 | mRNA |
