# HomeLIB

HomeLIB is a simple digital home library web app built during BeaverHacks 2026. It helps users search for books, save them to a personal library or wish list, track reading status, rate books, and write private notes.

We built HomeLIB for the **Beginner Track** as our first hackathon project.

## Inspiration

HomeLIB was inspired by a real request from one of our team member’s family members, who wanted a simple way to keep track of the books they had read.

When we started looking at existing book-tracking apps, we noticed that many of them were built around social media features. They focused on public reviews, friends, posts, reading challenges, advertisements, and recommendations. While those features can be useful for some people, they can also make the app feel overwhelming for users who simply want to remember what they read.

That stood out to us because not every reader wants another social platform. Some users, especially older readers or people who are less interested in social media, just want a private and simple way to organize their books, notes, ratings, and wish list.

That inspired us to build HomeLIB as a personal digital librarian: a clean web app focused on helping users remember what they read, what they thought about it, and what they want to read next.

## The Problem

A lot of people enjoy reading but struggle to keep track of what they have read, what they own, what they want to read next, and what they thought about each book.

Current book-tracking platforms often focus on social features like friends, posts, public reviews, reading challenges, advertisements, and recommendations. Those features can be useful for some users, but they can also distract from the main goal: helping someone remember and organize their own reading.

This can especially push away older readers or users who are not interested in using another social media-style platform.

We wanted to build something simpler: a personal digital librarian focused on the reader’s own books, notes, ratings, and wish list.

## Our Solution

HomeLIB is a clean web app that helps users organize their reading without social media clutter.

Users can search for books, view details, add books to a personal library, save books to a wish list, track reading status, add personal ratings, and write notes.

The goal is to make reading feel more organized without making the app feel overwhelming.

## What It Does

HomeLIB allows users to:

- Search for books using the Google Books API
- View book details such as title, author, publisher, description, page count, category, and rating
- Add books to a personal library
- Save books to a wish list
- Track reading status, including:
  - Want to Read
  - Reading
  - Completed
- Add personal star ratings
- Write and save private notes
- Use a dark, clean, simple interface
- Keep saved books, notes, ratings, and wish list items stored locally

## Who It Is For

HomeLIB is for readers who want a simple way to record the books they have read, own, or want to read.

Our target users include:

- Casual readers
- Older readers who may not want a social media-based book app
- Students
- Families
- People with physical book collections
- Anyone who wants a private reading journal instead of a public review platform

## What Makes HomeLIB Different

HomeLIB is not trying to be another social reading app.

Many existing platforms focus on what other people think about books. HomeLIB focuses on what the user thinks and remembers.

Instead of followers, posts, advertisements, or reading challenges, HomeLIB focuses on:

- Personal organization
- Private notes
- Personal ratings
- A simple library and wish list
- A clean interface that works for different ages and technical abilities

In the future, we want HomeLIB to recommend books based on the user’s own library, notes, and ratings instead of only genre or popularity.

## How We Built It

We built HomeLIB using **Flutter Web** and **Dart**.

We chose Flutter because it allowed us to quickly build a web app with a polished interface while still leaving room to expand to other platforms later.

We used the **Google Books API** to search for books and retrieve metadata like titles, authors, descriptions, covers, page counts, publishers, and ratings.

We used **Provider** for state management so that the search screen, library, wish list, and book detail popup could stay synced.

We used **SharedPreferences** to save the user’s library, wish list, reading status, ratings, and notes locally in the browser.

We deployed the project with **GitHub Pages** and **GitHub Actions** so the app can be accessed online.

## Tech Stack

- Flutter Web
- Dart
- Provider
- SharedPreferences
- Google Books API
- GitHub Pages
- GitHub Actions
- Git and GitHub
- ChatGPT
- Google Gemini

## Challenges We Ran Into

A lot broke during the hackathon.

Some of our biggest challenges were:

- Learning Dart and Flutter while building the project
- Connecting different screens together
- Keeping the search page, library, wish list, and popup synced
- Saving user data locally
- Handling missing or inconsistent data from the Google Books API
- Fixing Git merge conflicts
- Learning how to pull, merge, and avoid overwriting each other’s work
- Deploying the app to GitHub Pages
- Working with API keys and GitHub Secrets
- Making the app feel polished in a short amount of time

One major challenge was that we accidentally exposed our Google Books API key. We had to learn how API keys, GitHub Secrets, and restrictions work. We did not have enough time to build a full backend, so we focused on restricting the key and getting a working demo deployed.

Another major challenge was teamwork. Since this was our first hackathon, we had to learn quickly how to divide work, communicate changes, and fix problems when one person’s code affected another person’s screen.

## What We Learned

We learned that building an app is not just about writing code.

During this project, we learned how to:

- Build a Flutter Web app
- Use Dart
- Work with an external API
- Manage state with Provider
- Save data locally in the browser
- Deploy a web app with GitHub Pages
- Use GitHub Actions
- Resolve Git conflicts
- Work as a team under time pressure
- Make design decisions quickly
- Explain a project clearly for judging

Most importantly, we learned how to build, break, fix, and keep moving forward.

## Accomplishments We Are Proud Of

We are proud that HomeLIB is a working project, not just a mockup.

By the end of the hackathon, we built an app that can:

- Search real book data
- Display book covers and metadata
- Save books to a library
- Save books to a wish list
- Store personal ratings and notes
- Keep data saved locally
- Run as a deployed web app
- Present a polished dark interface

For our first hackathon, we are proud that we took an idea from a real problem, turned it into a working product, and learned enough to want to keep building it.

## What Is Next For HomeLIB

If we had another month, we would add:

- Manual book entry for books not found in the Google Books API
- Sorting by title, author, reading status, rating, or last read date
- Better ordering for books in a series
- User accounts and cloud sync
- Barcode scanning for physical books
- Better AI-powered recommendations based on the user’s own ratings and notes
- Tools to help users find where to buy or borrow physical and digital copies
- Import and export support
- Mobile improvements
- Support for other types of media, like movies and TV shows

We believe the same organizational idea behind HomeLIB could help people track not only books, but other media they care about too.

## Beginner Track Reflection

This was our first hackathon, and HomeLIB represents what we learned in 24 hours.

## AI Disclosure

We used AI tools during the project for debugging and code guidance since we were unfamiliar with Dart and Flutter

Specifically, AI helped us:

- Debug Flutter and Git issues
- Teacher for how certain things work in dart
- Generate suggestions for code organization in git

We reviewed, edited, tested, and committed the code ourselves. AI was used as a support tool while we learned and built the project.

We ran into bugs, merge conflicts, deployment problems, API issues, and design challenges. But we kept going, learned quickly, and built something real.

HomeLIB is more than just a reading tracker for us. It is proof that during our first hackathon, we were able to take an idea, turn it into a working product, and learn enough along the way to keep improving.
