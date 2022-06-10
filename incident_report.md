#### 2/5/2022, 18:00hrs PT

14hrs

We received reports of www and console not loading on Safari. Chrome worked fine. A refresh assisted by typeahead usually fixed the issue.

Upon investigation we identified this is because of http -> https redirect that was broken when we moved from Kubernetes Ingress to Istio Gateway. The issue was resolved at 9AM on 2/6/2022.
