# statuspage

We tried various Status Pages out there, and built this as a fun little hobby project with the intention of making setting up status pages as simple as possible.  

## Setup instructions

1. Fork this repository on github
2. Update urls-config.txt to include your urls

```
key1=https://example.com
key2=https://statsig.com
```
3. Update index.html and change the title

```
<title>My Status Page</title>
<h1>Services Status</h1>
```

4. Set up Pages on your github

![image](https://user-images.githubusercontent.com/74588208/121419015-5f4dc200-c920-11eb-9b14-a275ef5e2a19.png)


## How does it work?
This project uses Github actions to wake up every hour and run a shell script (health-check.sh).  This script runs 'curl' on every url in your config and appends the result of that run to a log file and commits it to the repository.  This log is then pulled dynamically from index.html and displayed in a easily consumable fashion.

## What does it not do?
1. Incident management
2. Outage duration tracking
3. Updating status root-cause

## Got new ideas?
Send in a PR - we'd love to integrate your ideas

![Screen Shot 2021-06-09 at 12 34 19 PM](https://user-images.githubusercontent.com/74588208/121417749-15b0a780-c91f-11eb-9c84-025cf5f5a3d4.png)

