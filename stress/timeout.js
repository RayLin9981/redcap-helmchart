import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Rate } from 'k6/metrics';

// 自訂 metrics
const http_failures = new Trend('http_failures');
const http_req_failed = new Rate('http_req_failed');

// 從環境變數取得測試目標
const TARGET_URL = __ENV.TARGET_URL || 'https://example.com';

export const options = {
  stages: [
    { duration: '30s', target: 1000 },
    { duration: '30s', target: 5000 },
    { duration: '30s', target: 10000 },
    { duration: '30s', target: 15000 },
    { duration: '30s', target: 20000 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_failed: ['rate<0.01'], // 失敗率低於 1%
    http_req_duration: ['p(95)<1000'], // 95% 請求小於 1 秒
  },
};

export default function () {
  const res = http.get(TARGET_URL);

  const ok = check(res, {
    'status is 200': (r) => r.status === 200,
  });

  if (!ok) {
    http_failures.add(1);
    http_req_failed.add(true);
  } else {
    http_req_failed.add(false);
  }

  sleep(0.5); // 模擬使用者等待
}

