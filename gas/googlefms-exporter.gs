function createJwtToken(appId, privateKey) {
  const header = {
    alg: "RS256",
    typ: "JWT",
  };
  const payload = {
    iss: appId,
    iat: Math.floor(Date.now() / 1000) - 60,
    exp: Math.floor(Date.now() / 1000) + 10 * 60,
  };

  const encodedString =
    Utilities.base64Encode(JSON.stringify(header)) +
    "." +
    Utilities.base64Encode(JSON.stringify(payload));
  const sigunature = Utilities.computeRsaSha256Signature(
    encodedString,
    privateKey
  );

  return encodedString + "." + Utilities.base64Encode(sigunature);
}

function getRandomStr(len) {
  var c = "abcdefghijklmnopqrstuvwxyz";
  var cl = c.length;
  var r = "";
  for (var i = 0; i < len; i++) {
    r += c[Math.floor(Math.random() * cl)];
  }
  return r;
}

function getGithubAccessToken(baseUrl, appId, installationId, privateKey) {
  const jwtToken = createJwtToken(appId, privateKey);
  const url = baseUrl + `/app/installations/${installationId}/access_tokens`;

  try {
    const response = UrlFetchApp.fetch(url, {
      method: "post",
      headers: {
        Authorization: `Bearer ${jwtToken}`,
      },
      muteHttpException: true,
    });

    return JSON.parse(response.getContentText()).token;
  } catch (e) {
    console.error(e);
  }
}

function getFormValue(e) {
  var itemResponses = e.response.getItemResponses();
  return itemResponses;
}

function triggerGithubActions(
  baseUrl,
  accessToken,
  userName,
  repo,
  workflow,
  payload
) {
  url =
    baseUrl +
    `/repos/${userName}/${repo}/actions/workflows/${workflow}/dispatches`;
  console.log(url);

  try {
    const response = UrlFetchApp.fetch(url, {
      method: "post",
      headers: {
        Authorization: `token ${accessToken}`,
        Accept: "application/vnd.github+json",
      },
      payload: JSON.stringify(payload),
    });
    console.log(response);
  } catch (e) {
    console.error(e);
  }
}

function main(e) {
  const baseUrl = "https://api.github.com";
  const properties = PropertiesService.getScriptProperties();
  const appId = properties.getProperty("appId");
  const installationId = properties.getProperty("installationId");
  const privateKey = properties.getProperty("privateKey").replace(/\\n/g, "\n");
  const githubUserName = properties.getProperty("userName");
  const githubRepo = properties.getProperty("repo");

  const accessToken = getGithubAccessToken(
    baseUrl,
    appId,
    installationId,
    privateKey
  );

  const formResponse = getFormValue(e);
  const department = formResponse[0].getResponse();
  const projectId = formResponse[1].getResponse();
  const folderAdmin = formResponse[2].getResponse();

  const prefix = getRandomStr(4);

  const inputDepartment = {
    name: department,
    folder_name: department,
    assign_roles_members: [
      {
        role: "roles/owner",
        members: ["user:" + folderAdmin],
      },
    ],
  };

  serviceProject = {
    name: projectId + "-" + prefix,
    project_id: projectId + "-" + prefix,
    department: department,
    host_project_name: "masem-cmn-nw",
    folder_name: projectId,
    assign_roles_members: [
      {
        role: "roles/owner",
        members: ["user:" + folderAdmin],
      },
    ],
    billing_account: "",
    labels: {
      "managed-by": "autoprocess",
    },
    network: {
      subnet_name: projectId + "-" + prefix,
      subnet_cidr_range: "",
      secondary_ip_ranges: [],
      assign_nw_user_members: ["user:" + folderAdmin],
    },
  };

  const payload = {
    ref: "main",
    inputs: {
      department: JSON.stringify(inputDepartment),
      service_project: JSON.stringify(serviceProject),
    },
  };

  triggerGithubActions(
    baseUrl,
    accessToken,
    githubUserName,
    githubRepo,
    "create-hierarchy.yaml",
    payload
  );
}
