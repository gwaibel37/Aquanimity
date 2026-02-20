# Congressional App Challenge - Team Progress Tracker
## 2026 Competition

**Team Name**: ________________________________

**Team Members**: 
1. Luke Sprecher
2. Gavin Waibel

**Congressional District**: 7th District

**Member of Congress**: Max Miller

**GitHub Repository URL**: https://github.com/gwaibel37/heimlich-app

---

## Quick Links & Important Dates

- **CAC Official Website**: https://www.congressionalappchallenge.us/
- **Video Link** (when ready): [Paste your URL here]

### Key Deadlines
- [ ] May 1, 2026: Submissions open
- [ ] October 30, 2026, 12:00 PM EDT: **FINAL SUBMISSION DEADLINE**
- [ ] January 15, 2027: Results embargo lifts

---

## Phase 1: Research & Planning (Weeks 1-3)

### Week 1: Research & Team Formation

**Date**: 1/12/2026

**Deliverables Checklist:**
- [X] Team formed
- [X] GitHub repository created
- [X] Repository has folder structure
- [X] Researched at least 5 previous CAC winning apps
- [X] Week 1 entry completed (this document)

**Winning Apps Researched:**

| App Name | Year | District | What Made It Win? | Key Takeaway |
|----------|------|----------|-------------------|--------------|
| 1. Gingerly | 2024 | OH-03 | Clean, minimal UI that works offline for emergencies. | Focus on low-friction design and speed. |
| 2. Civic Connect | 2024 | PA-01 | Simplified federal government info for seniors/students. | Civic tech is a winning category; focus on accessibility. |
| 3. Voter's Compass| 2024 | NY-24 | Translated complex candidate platforms into plain English. | Jargon is a barrier; simplification is a core feature. |
| 4. PositivePathways| 2024 | NC-01 | Used data tracking to give personalized user feedback. | Use complex backend data to drive simple user actions. |
| 5. Oasis | 2024 | MD-06 | Real-time mapping of resources using external APIs. | Integrating live APIs shows technical sophistication. |

**Week 1 Progress Notes:**
```
Team Formation:
- Members: Gavin and Luke
- Roles: Both developers

GitHub Setup:
- Repository created and cloned to local machine via VS Code.
- Established standard folder structure (then deleted it): /docs, /src, /assets, /tests.

Research Findings:
- Analyzed 5 past winners focusing on civic utility and API integration.
- Discovered that "Civic Connect" was a 2024 winner; decided to pivot our app a different direction to ensure originality.
- Identified that judges value apps that bridge the gap between complex data and the average citizen.

Challenges This Week:
- Initial "blank page syndrome" and deciding on a project that is technically feasible.
- Learning the Git workflow (Commit/Push) inside VS Code.

Next Week Goals:
- Brainstorm 5-10 specific features for the different app.
- Research other problems and possible solutions
```

---

### Week 2: Ideation & Project Selection

**Date**: 1/19/2026(ish)

**Deliverables Checklist:**
- [X] Brainstormed at least 3 app ideas
- [X] Evaluated each idea against CAC criteria
- [X] Selected final app concept
- [X] Week 2 entry completed (this document)

**App Ideas Brainstormed:**

| Idea # | App Name | Problem It Solves | Target Audience | Feasibility (1-5) | Selected? |
|--------|----------|-------------------|-----------------|-------------------|-----------|
| 1.     |          |                   |                 |                   |           |
| 2.     |          |                   |                 |                   |           |
| 3.     |          |                   |                 |                   |           |


**Selected App Concept:**
- **App Name**: Aquanimity
- **One-Sentence Purpose**: Promote attention spans and focus by discouraging phone use
- **Target Audience**: Anyone who works and needs to focus
- **Why We Chose This**: Its unique and is applicable to any audience

**Week 2 Progress Notes:**
```
Selection Rationale - why did you select the app over other ideas?:
- Its unique and practical
- Its solves a very large problem found amoung our peers

Next Week Goals/Plan (if you don't know, look at what's coming up next):
- Figure out what language to use and find out how to make an app cross-platform
```

---

### Week 3: Technical Planning & Role Assignment

**Date**: 1/28/2026 (ish)

**Deliverables Checklist:**
- [X] Development environment set up (all members)
- [X] Development timeline created
- [X] Week 3 updated (this document) 

**Technical Specifications:**
- **Platform**: iOS, Andriod, Browser, PC
- **Primary Programming Language(s)**: Dart (Flutter's Language)
- **Frameworks/Libraries**: Flutter Framework, shared_preferences (Persistent storage), vibration (Haptic feedback), and dart:math (Mathmematical animations)
- **Development Tools**: VSCode, Andriod Studio (SDK and Phone API), and Flutter SDK
- **Data Storage** (if applicable): Local device storage via shared_preferences

**Team Roles Assigned:**

| Team Member |          Primary Role           | Responsibilities |
|-------------|---------------------------------|------------------|
| 1. Gavin    | Understand what we have already |     Research     |
| 2. Luke     | Impliment new intresting things | Track use of AI  |

**Development Milestones:**

Preview of what's planned for the coming weeks:

| Week | Milestone | 
|------|-----------|
| 4-5  | Core functionality |  
| 6-7  | MVP features complete |  
| 8-9  | All features implemented |  
| 10-11 | Polish & documentation |  
| 12   | Video complete |  
| 13   | Ready for submission | 
| 14   | SUBMITTED | 

**Week 3 Progress Notes:**
```
Technical Decisions:
- Switched from a fixed dropdown menu to a numeric TextField for custom dive durations.
- Chose 'shared_preferences' for local data persistence to maintain a "Logbook" of total meters.
- Implemented 'vibration' plugin for physical haptic feedback during failure states ("The Bends").

Role Assignment:
(In this case)
- Lead Developer: Focused on core timer logic, state management, and lifecycle sensing.
- UI/UX Designer: Crafted the deep-sea gradients, glowing text effects, and menu.
- Systems Specialist: Managed environment setup, SDK linking, and hardware integration (Vibration/Storage).

Environment Setup:
- Linked VS Code with Android Studio by installing Android SDK Command-line Tools.
- Resolved "Android SDK not found" errors by configuring the flutter path.
- Successfully accepted Android licenses via the terminal to allow for physical device/emulator testing.

Challenges This Week:
- Debugged a "Kernel Snapshot" failure caused by an apostrophe in the project folder name (Invalid depfile).
- Resolved several "Deprecated Member" warnings by updating old 'withOpacity' code to the new '.withValues' standard.
- Managed the "Dead Code" error in the vibration logic by cleaning up null-aware operators.

Next Week Goals:
- Implement a "Reward System" with unlockable badges for reaching depth milestones.
- Begin "Stress Testing" long-duration dives to ensure background processes remain active.

```

---

## Phase 2: App Development (Weeks 4-7)

### Week 4: Core Development Begins

**Date**: 2/12/2026

**Monday Standup:**
- **[Gavin]** status/what are you working on: Trying to find what other libraries and dependancies we need
- **[Luke]** tatus/what are you working on: Continually improving and updating the existing app

**Deliverables Checklist:**
- [X] Basic app structure implemented
- [X] Initial UI being worked out/developed
- [X] Week 4 log entry completed

**Feature Development This Week:**

What features will be on your app?  Provide a list of what a user will expect to encounter and detail what each feature will include: 

- Dynamic Depth Engine: A real-time counter that converts every second of focus into one meter of ocean depth.
- Atmospheric Visual Immersion: A background color-interpolation system that lerps from surface blue to midnight black as the user descends.
- "The Bends" Penalty System: An app-lifecycle observer that detects if a user exits the app, immediately resetting progress and penalizing the "dive".
- Physical Haptic Feedback: A custom vibration "SOS" pattern (0ms wait, 500ms vibe, 200ms wait, 500ms vibe) that triggers upon a failed dive.
- Persistent Dive Logbook: Integration with device storage (SharedPreferences) to track and display the user's lifetime "Total Meters Explored".
- Custom Mission Parameters: A numeric input field that allows users to set specific dive durations in minutes or select an "Endless" mode.
- Heads-Up Display (HUD): Real-time "Target Depth" and "Status Message" indicators located in the screen corners.
- Achievements: A "Rewards" tab in the menu that unlocks badges like "Trench Runner" (for a 25-minute dive) or "Deepest Explorer" (for reaching 5,000m total).
- Pressure-Responsive Audio: Ambient oceanic "white noise" that adds a low-frequency hum as you go deeper
- Submarine "Hull" Upgrades: Allow users to "spend" their total logged meters to unlock different submarine colors or icons for their Radar??
- Post-Dive Statistics: A summary screen after a successful dive showing "Atmospheric Pressure Resisted" and "Oxygen Conserved" to add scientific flavor text
- Focus Tests: Notifications that give a penalty (3 strikes youre out?) system [Need Firebase?]


**Week 4 Progress Notes:**
```
Accomplishments:
- 

Technical Challenges:
- 

Solutions Found:
- 

Next Week Goals:
- 
```

---

### Week 5: Core Development Continues

**Date**: ________________

**Monday Standup:**
- **[Member 1]** status/what are you working on: ______________
- **[Member 2]** tatus/what are you working on: ______________
- **[Member 3]** tatus/what are you working on: ______________  

**Deliverables Checklist:**
- [ ] Core feature #1 functional
- [ ] Progress toward first prototype
- [ ] Week 5 log entry completed

**Feature Development This Week:**

Provide a status on the various features that you plan to have on your app: 

**Week 5 Progress Notes:**
```
Accomplishments:
- 

Technical Challenges:
- 

Solutions Found:
- 

Next Week Goals:
- 
```

---

### Week 6: Feature Development

**Date**: ________________

**Monday Standup:**
- **[Member 1]** status/what are you working on: ______________
- **[Member 2]** tatus/what are you working on: ______________
- **[Member 3]** tatus/what are you working on: ______________  

**Deliverables Checklist:**
- [ ] MVP (Minimum Viable Product) features being implemented
- [ ] Week 6 log entry completed

**Feature Development This Week:**

Provide a status on the various features that you plan to have on your app:

**Week 6 Progress Notes:**
```
Accomplishments:
- 

Technical Challenges:
- 

Solutions Found:
- 

Next Week Goals:
- 
```

---

### Week 7: Feature Development & Mid-Project Review

**Date**: ________________

**Monday Standup:**
- **[Member 1]** status/what are you working on: ______________
- **[Member 2]** tatus/what are you working on: ______________
- **[Member 3]** tatus/what are you working on: ______________  

**Deliverables Checklist:**
- [ ] All MVP features implemented
- [ ] UI refined and user-friendly
- [ ] Testing documentation started
- [ ] Week 7 log entry completed
- [ ] **MID-PROJECT DEMO prepared for instructor**

**Feature Development This Week:**

Provide a status on the various features that you plan to have on your app: 

**Mid-Project Review Preparation:**
- [ ] Demo presentation prepared
- [ ] Current functionality documented
- [ ] Known issues/bugs listed
- [ ] Remaining work identified


### **Week 7 Progress Notes:**
```
Accomplishments:
- 

Technical Challenges:
- 

Solutions Found:
- 

Next Week Goals:
- 
```
---

## Phase 3: Development Wrap Up (Weeks 8-11)

### Week 8: Feature Completion

**Date**: ________________

**Monday Standup:**
- **[Member 1]** status/what are you working on: ______________
- **[Member 2]** tatus/what are you working on: ______________
- **[Member 3]** tatus/what are you working on: ______________  

**Deliverables Checklist:**
- [ ] All MVP features 100% complete
- [ ] Nice-to-have features in progress
- [ ] Week 8 log entry completed

**Feature Development This Week:**

Provide a status on the various features that you plan to have on your app:


**Week 8 Progress Notes:**
```
Accomplishments:
- 

Technical Challenges:
- 

Solutions Found:
- 

Next Week Goals:
- 
```

---

### Week 9: Testing & Bug Fixes

**Date**: ________________

**Monday Standup:**
- **[Member 1]** status/what are you working on: ______________
- **[Member 2]** tatus/what are you working on: ______________
- **[Member 3]** tatus/what are you working on: ______________  

**Deliverables Checklist:**
- [ ] Comprehensive testing completed
- [ ] Bug list created and prioritized
- [ ] Critical bugs fixed
- [ ] Week 9 log entry completed

**Testing & Bugs:**

| Test Scenario | Result | Bugs Found | Priority | Fixed? |
|---------------|--------|------------|----------|--------|
|               |        |            | ☐ High<br>☐ Medium<br>☐ Low |  |
|               |        |            | ☐ High<br>☐ Medium<br>☐ Low |  |
|               |        |            | ☐ High<br>☐ Medium<br>☐ Low |  |



**Week 9 Progress Notes:**
```
Accomplishments:
- 

Technical Challenges:
- 

Solutions Found:
- 

Next Week Goals:
- 
```

---

### Week 10: Code Polish & Documentation

**Date**: ________________

**Monday Standup:**
- **[Member 1]** status/what are you working on: ______________
- **[Member 2]** tatus/what are you working on: ______________
- **[Member 3]** tatus/what are you working on: ______________  

**Deliverables Checklist:**
- [ ] Code cleaned up and well-commented
- [ ] All known bugs fixed
- [ ] README.md completed
- [ ] Week 10 log entry completed

**Documentation Progress:**
- [ ] README.md includes project overview
- [ ] README.md includes setup/installation instructions
- [ ] README.md includes usage instructions
- [ ] README.md includes technology stack
- [ ] All code files have header comments
- [ ] Complex functions are commented
- [ ] AI usage documented (if applicable)


**Week 10 Progress Notes:**
```
Accomplishments:
- 

Technical Challenges:
- 

Solutions Found:
- 

Next Week Goals:
- 
```

---

### Week 11: Final Testing & Video Planning

**Date**: ________________

**Monday Standup:**
- **[Member 1]** status/what are you working on: ______________
- **[Member 2]** tatus/what are you working on: ______________
- **[Member 3]** tatus/what are you working on: ______________  

**Deliverables Checklist:**
- [ ] Final testing across scenarios/devices
- [ ] Source code documentation complete
- [ ] Video script/planning started
- [ ] Week 11 log entry completed

**Final Testing Results:**

| Test Type | Passed? | Notes |
|-----------|---------|-------|
| Functionality |  |  |
| User Interface |  |  |
| Error Handling |  |  |
| Performance |  |  |
| Compatibility |  |  |


**Week 11 Progress Notes:**
```
Accomplishments:
- 

Technical Challenges:
- 

Solutions Found:
- 

Next Week Goals:
- 
```

---

## Phase 4: Submission Preparation (Weeks 12-15)

### Week 12: Video Creation

**Date**: ________________

**Deliverables Checklist:**
- [ ] Video script/storyboard completed
- [ ] Video filmed
- [ ] Video edited
- [ ] Video uploaded to YouTube/Vimeo as "public"
- [ ] Video link tested and confirmed working
- [ ] Week 12 log entry completed

**Video Script Outline:**

```
INTRODUCTION (10-15 seconds)
- Team member names: _______________________________________
- App name: _______________________________________

PURPOSE (15-20 seconds)
- One-sentence purpose: _______________________________________
- Target audience: _______________________________________

TECHNICAL OVERVIEW (20-30 seconds)
- Programming languages: _______________________________________
- Key tools/frameworks: _______________________________________

DEMONSTRATION (60-90 seconds)
- Feature 1 demo: _______________________________________
- Feature 2 demo: _______________________________________
- Feature 3 demo: _______________________________________

CONCLUSION (10-15 seconds)
- Closing statement: _______________________________________

TOTAL TIME: _______ (must be 1-3 minutes)
```

**Video Checklist:**
- [ ] Length is between 1-3 minutes
- [ ] All team member names shown/spoken
- [ ] App name clearly stated
- [ ] Purpose explained in one clear sentence
- [ ] Target audience explained
- [ ] Tools and languages mentioned
- [ ] Functionality showcased
- [ ] Good audio quality
- [ ] Clear visuals
- [ ] Professional presentation
- [ ] Set to "public" on YouTube/Vimeo

**Video Link**: _______________________________________

**Week 12 Progress Notes:**
```
Video Production Process:
- 

Challenges:
- 

Next Week Goals:
- 
```

---

### Week 13: Application Questions & Final Review

**Date**: ________________

**Deliverables Checklist:**
- [ ] All application questions drafted
- [ ] Final testing completed
- [ ] All GitHub documentation finalized
- [ ] README.md includes setup instructions
- [ ] All code committed with final message
- [ ] Week 13 log entry completed

**Application Questions (DRAFTS):**

**1. What is the title of your app?**
```
Answer:


```

**2. Explain the app's purpose.**
```
Answer:




```

**3. What inspired you to create this app?**
```
Answer:




```

**4. What technical/coding difficulty did you face in programming your app, and how did you address this technical challenge?**
```
Answer:






```

**5. What did you learn while participating in the CAC? What was your biggest takeaway?**
```
Answer:






```

**6. What would you change about your app if you were to create a 2.0 version?**
```
Answer:

```

**Week 13 Progress Notes:**
```
Accomplishments:
- 

Final Preparations:
- 

Confidence Level:
- 

Next Week Goals:
- 
```

---

### Week 14 and 15: SUBMISSION WEEKS

**Date**: ________________

**PRE-SUBMISSION FINAL CHECKLIST:**

**GitHub Repository:**
- [ ] All code committed and pushed
- [ ] README.md complete and accurate
- [ ] All documentation files complete
- [ ] Repository is well-organized
- [ ] No temporary/test files in main branch

**Video:**
- [ ] Video link tested and working
- [ ] Video is set to "public"
- [ ] Video length is 1-3 minutes
- [ ] All required elements included

**Application:**
- [ ] All questions answered and reviewed
- [ ] Answers proofread for grammar/spelling
- [ ] All team member information accurate

**Registration & Submission:**
- [ ] Team account created at https://www.congressionalappchallenge.us/
- [ ] All 3 team members have profiles
- [ ] Personal profiles completed
- [ ] Eligibility quiz completed and passed
- [ ] Application form filled out completely
- [ ] Video link added correctly
- [ ] All questions copied into application
- [ ] Confirmation email received

**Backup:**
- [ ] All project files backed up locally
- [ ] Copy of video saved locally
- [ ] Copy of all application answers saved

**Submission Date & Time**: _______________________________________

**Week 14 / 15 Progress Notes:**


## AI Usage Documentation


**If you used AI tools, document them here:**

### AI Tool #1: _______________________________________

**What it was used for:**

**Specific examples of usage:**

**How you modified/improved AI output:**

### AI Tool #2: _______________________________________

**What it was used for:**

**Specific examples of usage:**

**How you modified/improved AI output:**

---

## External Resources & Libraries Used

**Document all external code, libraries, or resources used:**

| Resource/Library | Purpose | Source/URL | License |
|------------------|---------|------------|---------|
|                  |         |            |         |
|                  |         |            |         |
|                  |         |            |         |

---


*Last Updated: [24 Jan 2026]*
