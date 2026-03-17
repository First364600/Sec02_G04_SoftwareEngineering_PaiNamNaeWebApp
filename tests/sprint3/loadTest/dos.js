import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 500 },
    { duration: '30s', target: 1000 },
    { duration: '30s', target: 2000 },
    { duration: '30s', target: 4000 },
    { duration: '30s', target: 8000 },
    { duration: '30s', target: 0 },
  ],
};

/*export const options = {
  scenarios: {
    forever_test: {
      executor: 'constant-vus',
      vus: 100,
      duration: '999h',
    },
  },
};
*/

export default function () {
  let res = http.get('http://host.docker.internal:3001');

  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  sleep(1);
}

export function handleSummary(data) {
  return {
    '/scripts/summary.json': JSON.stringify(data),
    stdout: JSON.stringify(data, null, 2),
  };
}