# Dreamscape R11 — AI Dream Interpretation & Lucidity Tracking

## Goals
- Advanced AI-powered dream interpretation using on-device Apple Intelligence
- Symbol recognition with machine learning
- Lucidity tracking and prompts

## Features

### AI Dream Analysis (Apple Intelligence)
- Use `AppIntents` framework for dream summarization
- `NaturalLanguage` framework for symbol extraction
- Generate personalized interpretations based on dream history
- Detect recurring patterns across dreams
- Contextual insights based on time, mood, and life events

### Symbol Recognition Engine
- Train ML model to recognize custom symbols specific to user's dreams
- Categorize symbols: people, places, objects, emotions, creatures, abstract
- Track symbol frequency and evolution over time
- Visual symbol graph showing relationships

### Lucidity Tracking
- Lucidity level indicator (1-5 scale)
- Reality check reminders via notification
- Lucidity training tips based on dream history
- "Woke up inside the dream" moments capture
- Track what triggers lucidity for each user

### Dream Quality Metrics
- Vividness rating after recording
- Emotional intensity scale
- Memory retention score (how well dream was remembered)
- Sleep quality correlation (if HealthKit available)

## Technical
- NaturalLanguage framework for entity extraction
- CoreML for custom symbol classification
- AppIntents for Siri Shortcuts integration
- HealthKit for sleep data correlation

## UI Updates
- New "Analysis" tab with AI insights
- Symbol detail pages with interpretation history
- Lucidity calendar heat map
- Dream quality post-recording flow

## Deliverables
- [ ] AI summarization pipeline
- [ ] Symbol recognition with NL framework
- [ ] Lucidity level tracking
- [ ] Dream quality metrics
- [ ] Analysis tab UI
- [ ] Symbol relationship graph
