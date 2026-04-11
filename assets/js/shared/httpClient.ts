const DEFAULT_HEADERS = {
  'Content-Type': 'application/json',
};

const buildAuthenticationHeader = () => {
  return {
    ...DEFAULT_HEADERS,
  };
};

const deleteRequest = async <T>(url: string, data?: T): Promise<string> => {
  const response = await fetch(url, {
    headers: buildAuthenticationHeader(),
    method: 'DELETE',
    body: data && JSON.stringify(data),
  });

  const splittedUrl = response.url.split('/');
  const deletedId = splittedUrl[splittedUrl.length - 1];

  if (!response.ok) {
    console.error(
      'Error deleting resource:',
      response.status,
      response.statusText,
    );
  }

  return deletedId;
};

const get = async <R>(url: string): Promise<R> => {
  const response = await fetch(url, {
    headers: buildAuthenticationHeader(),
  });
  const jsonData = await response.json();
  return jsonData;
};

const patch = async <T, R>(url: string, data: T): Promise<R> => {
  const response = await fetch(url, {
    headers: buildAuthenticationHeader(),
    method: 'PATCH',
    body: JSON.stringify(data),
  });

  const jsonData = (await response.json()) as R;

  if (!response.ok) {
    console.error(
      'Error patching resource:',
      response.status,
      response.statusText,
    );
  }

  return jsonData;
};

const put = async <T, R>(url: string, data?: T): Promise<R> => {
  const response = await fetch(url, {
    headers: buildAuthenticationHeader(),
    method: 'PUT',
    body: data && JSON.stringify(data),
  });

  const jsonData = (await response.json()) as R;

  if (!response.ok) {
    console.error(
      'Error putting resource:',
      response.status,
      response.statusText,
    );
    // Throw error with status code for proper error handling
    const error: any = new Error(
      `HTTP ${response.status}: ${response.statusText}`,
    );
    error.status = response.status;
    error.statusText = response.statusText;
    error.data = jsonData;
    throw error;
  }

  return jsonData;
};

const post = async <T, R>(url: string, data: T): Promise<R> => {
  const response = await fetch(url, {
    headers: buildAuthenticationHeader(),
    method: 'POST',
    body: JSON.stringify(data),
  });

  const jsonText = await response.text();
  const jsonData = jsonText ? (JSON.parse(jsonText) as R) : ({} as R);

  if (!response.ok) {
    console.error(
      'Error posting resource:',
      response.status,
      response.statusText,
    );
    // Throw error with status code for proper error handling
    const error: any = new Error(
      `HTTP ${response.status}: ${response.statusText}`,
    );
    error.status = response.status;
    error.statusText = response.statusText;
    error.data = jsonData;
    throw error;
  }

  return jsonData;
};

export default {
  delete: deleteRequest,
  get,
  patch,
  put,
  post,
};
