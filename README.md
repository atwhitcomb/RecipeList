# RecipeList

### Steps to Run the App
To run with the base endpoint (ending in recipes.json), just run `RecipeList` as expected. To change the endpoint, simply change it within
RecipeListApp.swift under the calculated variable `recipeFetcher`.  

### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?
My primary focus with this project was ensuring the UI component, written using `SwiftUI`, worked as expected; while I have done quite a bit 
with SwiftUI, I do not have the certainty with it as I do with `UIKit`. My secondary focus was the image loader, mostly because I wanted to
optimize it as well as I could (and arguably overengineered it in the process). 

### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?
I would approximate the amount of time I spent on this project to be a bit over 6 hours, though this was due to only spending a couple of
hours each of the three nights I worked on it. The first night, I spent writing how to download the recipe list and the start of the UI done.
The second night, I finished working on the UI and got the image loader working. The final night, I cleaned up the image loader logic, the UI 
appearance, and wrote the testing that I did.

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?
I don't believe I made any significant trade-offs in my approach. With the inline comments I explained the decisions I made and where I spent
extra time engineering.

### Weakest Part of the Project: What do you think is the weakest part of your project?
The weakest part of my project is the testing, because in my expediency I did not create a separate controller to manage networking calls,
which meant that I did not have an easier manner to test the parsing and caching of data.

### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.
While I did not come away with any new insights or faced any constraints working on this project, I will say, regardless of decision to
continue to move forward or not, I do appreciate frontloading this sort of assignment and also providing a rather open ended timeline to
complete this, especially as we go into the holidays.

One suggestion I do want to make is that while the problem itself is a great balance of being able to express one's skill and conciseness,
having to submit a public repository is not ideal for someone is currently employed. While the odds that someone will see this repository is
slim, given effectively every developer has a Github account and private hosting is available for free, it would be nice to be able to submit
by inviting some account to the repository (not even a developer's account, just some company owned account).
