# Creating a Simple GitHub Pull Request

I want to add a link in a page from the DataTalksClub’s Data Engineering Zoomcamp GitHub repository.

![s01](dtc/pull-request/s01.png)

The link I want to add is **Notes by Alain Boisvert** pointing to this URL:
<https://github.com/boisalai/de-zoomcamp-2023/blob/main/week2.md>.

To do this, I will use **pull requests**.
Pull requests let you tell others about changes you’ve pushed to a branch in a repository on GitHub.

Before starting, I recommend you to watch this excellent video on Youtube: [Creating a Simple Github Pull
Request](https://www.youtube.com/watch?v=rgbCcBNZcdQ) from Jake Vanderplas. And take the opportunity to give it a star!
:star:

Then, to create a pull request, I will do the following steps:

1. Fork the GitHub repository
2. Clone this forked repo
3. Create a new branch
4. Modify the README.md file
5. Commit and push
6. Compare and pull request

## 1. Fork the GitHub repository

Go to the GitHub repository <https://github.com/DataTalksClub/data-engineering-zoomcamp> and click on the **Fork**
button at the top right.

A **fork** is a copy of a repository. Forking a repository allows me to change the README page without affecting the
original project.

Click on the green **Create fork** button at the bottom.

|                                  |                                  |
|----------------------------------|----------------------------------|
| ![s13](dtc/pull-request/s02.png) | ![s14](dtc/pull-request/s03.png) |

A fork is created in my personal GitHub account. We see at the top left, it is indicated "forked from
[DataTalksClub/data-engineering-zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp)".

![s04](dtc/pull-request/s04.png)

## 2. Clone this forked repo

Now, clone this forked repo to my computer.

To do this, click on the **\<\> Code** button and copy the right link.

In my case, I have already installed the ssh keys to interact with GitHub so I will take the corresponding link to
**SSH**.

![s05](dtc/pull-request/s05.png)

In a terminal window, run the following command.

``` bash
git clone git@github.com:boisalai/data-engineering-zoomcamp.git
```

We should see this in the terminal window.

![s06](dtc/pull-request/s06.png)

## 3. Create a new branch

Now, we need to create a new branch. I propose to call this new branch **add-link-to-week2**.

To create the new branch, just run this command.

``` bash
cd data-engineering-zoomcap
git checkout -b add-link-to-week2
```

![s07](dtc/pull-request/s07.png)

## 4. Modify the README.md file by adding a link to it

In VS Code, add the link to the README.md file like this.

![s08](dtc/pull-request/s08.png)

The `git diff` command helps us to see what changes have been made.

![s09](dtc/pull-request/s09.png)

Type `:q` to quit.

## 5. Commit and push

Commit and push this local branch **add-link-to-week2** to our remote forked repository. Note that **origin** is the
conventional shorthand name of the url for the remote repository.

![s10](dtc/pull-request/s10.png)

## 6. Compare and pull request

Back to the forked repo, you will see a message indicating our push.

![s11](dtc/pull-request/s11.png)

Click on the green **Compare & pull request** button to open a pull request.

![s12](dtc/pull-request/s12.png)

Add a message informing the repo owner of the changes you made and click on the green **Create pull request**.

You can click on the tabs to check if everything is correct.

|                                  |                                  |
|----------------------------------|----------------------------------|
| ![s13](dtc/pull-request/s13.png) | ![s14](dtc/pull-request/s14.png) |

Congratulations! For some of you, this may be the first pull request.

For my part, it was really my first pull request of all my life. :wink:
