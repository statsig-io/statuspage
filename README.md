[![Health Check](../../actions/workflows/health-check.yml/badge.svg)](../../actions/workflows/health-check.yml)

# Statsig's Open-Source Status Page

We tried various Status Pages out there, and built this as a fun little hobby project to make status pages as simple as possible.

## Demo

- https://status.statsig.com

## Setup instructions

1. Fork the [template repository](https://github.com/statsig-io/statuspage/).
2. Update `urls.cfg` to include your urls.

```cfg
key1=https://example.com
key2=https://statsig.com
```

3. Update `index.html` and change the title.

```html
<title>My Status Page</title>
<h1>Services Status</h1>
```

4. Set up GitHub Pages for your repository.

![image](https://user-images.githubusercontent.com/74588208/121419015-5f4dc200-c920-11eb-9b14-a275ef5e2a19.png)

## How does it work?

This project uses Github actions to wake up every hour and run a shell script (`health-check.sh`). This script runs `curl` on every url in your config and appends the result of that run to a log file and commits it to the repository. This log is then pulled dynamically from `index.html` and displayed in a easily consumable fashion. You can also run that script from your own infrastructure to update the status page more often.

## What does it not do (yet)?

1. Incident management.
2. Outage duration tracking.
3. Updating status root-cause.

## Got new ideas?

Send in a PR - we'd love to integrate your ideas.

## In case...

You are looking for a developer friendly Feature flags, and A/B experimentation service for your product, check out: https://www.statsig.com

![Screen Shot 2021-06-10 at 1 25 43 AM](https://user-images.githubusercontent.com/74588208/121491467-d455e180-c98a-11eb-8514-73e6707737c4.png)
