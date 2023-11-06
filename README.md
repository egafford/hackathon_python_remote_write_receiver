# Python Remote Write Receiver
### 2023/11 Hackathon, Elise Gafford

## Rationale
As Cirrus embarks on our glorious journey of aggregating k8s
metrics, we've identified the following design priorities:
- We favor avoidance of CloudZero code installed within the
  customer’s cluster
- We favor leveraging industry standard Kubernetes 
  monitoring solutions
- We favor data push from customer’s cluster vs. CloudZero
  pulling

While the k8s observability market is severely Balkanized,
Prometheus is far and away the leader in the OSS space.
In our customer conversations, roughly half of our customers
have Prometheus on their cluster.

Prometheus has provided the `scrape_config` feature, which
allows users to configure which metrics to query, for quite
some time. In its most recent stable version, however, it
also released the `remote_write` feature, which allows it
to report data to external endpoints.

Thus was the dream of a configuration-only, agentless k8s
cost observability solution born.

## Objective

This project intended to create a remote_write receiver:
- In Python
- That wrote to S3
- And as a personal goal, could not be used as production
  code, because that's frequently how you get ants. :)

I set these goals because:
- In reviewing remote_write receiver options, I noted that
  the (admittedly small number of) similar repos I found
  were extremely small.
- It seemed like a great opportunity to kick the tires on
  our design idea; even if it failed, we'd have learned
  useful things.
- The options for remote_write receivers are mostly in
  Golang, and I want to keep Cirrus' codebase Python
  wherever possible.

# Results

I didn't get as far as I'd have liked; the queueing and
writing to S3 that I'd envisioned didn't happen. Made some
friends along the way, though.

First, I learned that no, really, there's no one doing this
in Python. The only references I finally found for how to
implement a remote_write receiver in Python were this 
[StackOverflow thread](https://stackoverflow.com/questions/74850324/deserializing-prometheus-remote-write-protobuf-output-in-python/74850876)
and this [partially-English language blog post](https://hackmd.io/@enidchen/BkRRUcbj9).
Python's handling and compiling of protobuffers in
particular took *many* of the working hours I'd hoped to pour
into S3 integration, where a Golang equivalent would have
worked off the shelf. This lack of community support gives
me some pause: we'd definitely need to load-test any
similar solution if we go to prod with one.

Second, remote_write receivers can only filter metrics by
label, not by Prometheus metric name as I'd hoped. This
isn't disqualifying and I believe we can configure that
as needed in our scrape_config, but it does make any
similar solution a bit more error-prone.

Third, though, the brevity of the code required for basic
integration with Prometheus once all the magic incantations
were known is quite striking. Compared with the amount of 
code that must run in the customer
env that is our amazon-cloudwatch-agent, this is tiny and
can run in our accounts. This alone very much does
suggest to me that the way forward may be promising from
here.

## Usage

From the root directory:
- You don't need to run `./scripts/protobuf.sh`, but you
  could if it would make you happy. 
- Run `./scripts/prometheus.sh`. This should eventually
  give you the address of your shiny new local Prometheus
  install, which will sit around monitoring itself like a
  boss.
  *Note that this solution uses an arch-specific Minikube
  distro: if you're on an x86 chip or not on a Mac, you'll
  need to download a different installer.*
- In a separate terminal (or with the prior process
  backgrounded), run `./scripts/flask.sh`, which will
  stand up a tiny webserver to listen to and decode
  the most basic messages from Prometheus. It doesn't do
  much with them at present, but from here we can do more
  or less anything we like with them.

## Conclusion

Especially in light of our ongoing customer conversations,
it seemed important to kick the tires on this soon. The
essential findings are:
- Yes, rolling our own remote_write receiver that can run
  in our envs in our preferred language is possible,
- And the codebase would be much smaller and more
  maintainable than our current solution,
- But doing so in Python seems not to be something that's
  common in the community at all, so there's some more
  tire kicking to do from here if we keep marching down
  this road.
