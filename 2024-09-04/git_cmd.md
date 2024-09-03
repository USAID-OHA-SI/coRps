# git credentials
### [introduce yourself to git](https://happygitwithr.com/hello-git)

git config --global user.name "Jane Doe"

git config --global user.email "jane@example.com"

git config --global --list


### create a PAT (for HTTPS)
  - [GH PAT](https://github.com/settings/tokens)
  - {r} usethis::create_github_token()

# Initiate Project

###create a repo on GitHub
  - [USAID-OHA-SI Repos](https://github.com/orgs/USAID-OHA-SI/repositories#) 
  -  New repository > Name, Description, Public,  Initialize with ReadME, add .gitignore, choose a license (MIT)
  - Copy web URL (look for the green buttom labeled <> Code; you want the HTTPS url)
  
### Local setup
  - Clone locally /Open in RStudio
  - Create Project > Version Control > Git 
  - paste url (HTTPS)
  
# Local workflow
  - {r} glamr::si_setup()
  - Open the terminal ALT + SHIFT + M

git status

git diff

q

git add

git add .gitignore

git status

git -m "add more specific gitignore files for safety"

git status

git add .

git commit -m "init proj and readme"

  - create a script

git push

git add .

git commit -m "useful script"

git push

  - update script
  
git status

git restore test.R

git commit -am "add something"

git log

q

  - look at commits on GitHub

git fetch

git pull

  -  create an issue

git branch dev_hotfix

git branch

git switch dev_hotfix

git push

git push --set-upstream origin dev_hotfix

  - create code fix

git status

git push

  - look at issue on GitHub

git switch main

git merge dev_hotfix

git branch -d dev_hotfix

git push

git branch

git branch dev_dos

git switch dev_dos

git push --set-upstream origin dev_dos

  - change R file
  
git status

git commit -am "change something"

git push

git status

  - create PR on GitHub
  - merge PR on GitHub

git switch main

git fetch

git pull

git branch -d dev_dos

  - edit README on GitHub

git status

  - look at readme locally
  - edit readme locally

git status

git commit -am "cool things added"

  - OH NO! Errors Abound!
  
git fetch

git pull

  - manually resolve merge conflict between arrows
  
git commit -am "resolve merge conflict"

git push

git log

q


## [GitHub Best Practices](https://github.com/ICPI/DIV/blob/master/Best_Practices/Best%20Practices%20-%20GitHub.md)
- **Each repo should be its own project** - Standard practice working in GitHub is to have each project you work on be its own, standalone repository, or repo for short. This setup may seem odd to those use to building out a judicious filing system (for example, having all projects under the TB and Treatment Cluster to all sit under that repo). The reason each project is separated into to its own repo is to keep projects "binned." When you clone a repo, rather than having to download and add all the projects that fall under one "folder", you are cloning a single, contained project. This practice also helps with file management. Rather than having to dig through issues, commit messages, pulls, etc. that could span a wide spectrum when lots of projects fall within one cluster folder. However, if you are running a quick request or one time query of the data, storing the code within a cluster folder is a better option than creating a whole, new repo for a few lines of code.
- **Commit early and often** - GitHub is built upon Git, which is an open source version control system. Users make "commits" to the master repo to document changes. Git pushes the changes or diffs made between your local file and the master repo. If you make small changes and commit them frequently, it makes it extremely easy to track what changed and when.     
- **Don’t commit data that isn’t public** - ICPI utilizes a public version of GitHub. A large majority of the data we deal with is SBU and should only stored on your local machine, not on the cloud. To avoid errantly committing SBU data, you should modify your .gitignore to include \*.txt, \*.xlsx, \*.RDS, etc.   This point also is inclusive of screenshots in issues, for example, that may be sensitive.
- **Document, Document, Document** (code, README, wiki, issues) - One critical concept all analysts should adopt is heavy documentation practices. This means making comments in your code and GitHub so that collaborators and future you get what you're doing and why. This makes your code much more accessible, even for less technically folks, since it enables observers to more clearly understand what is going on with your work. This practice translates to GitHub in the form of key documents. First and foremost, your repos should include useful README files that clearly describe the purpose, content, and other useful information. You can dive deeper and supplement your README file with additional useful information, storing that in the wiki section of your repo.  It's also key for you to add descriptive commit messages. This act will allow you and your collaborators to easily understand the changes that were made. Lastly, you should also identify issues or outstanding tasks with well documented issues which can be assigned to other collaborators.
- **Install a Git client** - To make the most of GitHub, you should install git on your computer, which will allow you to push changes directly from your local machine to GitHub. This process does require some setup and getting use to some basic git commands. To assist in this process and help visualize what you're doing, it's also advisable to install a git client such as GitKraken, SourceTree, and GitHub Desktop. If you are working with R, I would also highly recommend you setup git with RStudio. These git clients will make your life easier in interacting with GitHub and allow you to leverage it's full potential.
- **Fork > Clone > Pull** - GitHub is a collaborative platform and you can think of it as a more nuanced version of Google Docs. Everything you post to GitHub (at least on the ICPI organization) is public and accessible to everyone. Other people can suggest alternative coding approaches, bug fixes, or contribute to your analysis. The best workflow to accomplish this as a contributor is to follow a work flow of fork, clone, pull. You'll start by making a copy of the original repo you want to edit or contribute to; this process is called forking. After you fork the repo, you will have your own version in your list of repos. The next step is to clone, or download, your copy of your repo to your local machine. Once there, you can make your edits and test them (committing frequently with well documented commit messages). Once ready, you can now conduct a pull request to the original repo, letting the owner know that you suggesting edits. They can see and review all the commits in your pull request and, if they like them, they can approve your pull, which gets merged into the original repo. It's best to follow this workflow with one person managing a repo to avoided overlapping and merge issues.
- **Utilize Markdown** - Related to the best practice above of documenting, it's best to take advantage of Markdown documentation. Markdown is a very simplistic formatting of text documents (eg bold, lists, headers, hyperlinking, tables, images, etc.). Markdown is easily converted into HTML and works with issues, commits, README files, etc. :raised_hands: You can use Markdown to convert your GitHub repo to a site. It also has great integration if you work with R and use Rmd files when posting online to share analysis.
- **Keep your repo and issues up to date and clean** - Over time, it's easy to have mission creep with your repo, let issue hang, or forget to keep your main README up to date. Keeping everything updated makes it easy to jump back and forth between project, return back to your project after a few months, or have a collaborator jump right in. Start off with good practices by having folder structure (Scripts, RawData, Documents, Outputs, etc.) so that everything has a logical home.