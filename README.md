# Slackers.

> Kinda a meal prep guide. Actually a life guide.

## Stack
- **Frontend**: Vanilla HTML/CSS/JS (single file, zero build step)
- **Auth + Database**: Supabase (free tier)
- **Hosting**: Vercel (free Hobby tier)

## Deploy steps

### 1. Run the Supabase schema
- Go to your Supabase project → SQL Editor
- Copy the contents of `supabase-schema.sql`
- Click **Run**

### 2. Push to GitHub
```bash
git init
git add .
git commit -m "Initial Slackers app"
git branch -M main
git remote add origin https://github.com/hubberdione/slacker.app.git
git push -u origin main
```

### 3. Connect to Vercel
- Go to [vercel.com](https://vercel.com)
- Click **Add New → Project**
- Import `hubberdione/slacker.app` from GitHub
- Click **Deploy** (zero config needed)

### 4. Done 🎉
Your app is live at `https://slacker-app.vercel.app` (or similar)

## Features
- 🔐 Email auth via Supabase
- 🧊 Fridge & ingredient tracker with nutritional info
- 🍳 Meal suggestions based ONLY on what you have
- ⏱ 24-hour time planner (cooking deducts from free time)
- 💰 Budget tracker (income, expenses, net balance)
- 💳 Debt tracker with snowball strategy
- 🎯 Goals & savings tracker
- 👤 Gender-aware personality (male/female/other)
- ☁️ All data syncs to Supabase in real time
