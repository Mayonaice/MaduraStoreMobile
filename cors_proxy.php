<?php
// CORS Proxy untuk Flutter Web
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// Tangani OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header('HTTP/1.1 200 OK');
    exit();
}

// URL target yang akan di-proxy
$targetUrl = isset($_GET['url']) ? $_GET['url'] : '';
if (empty($targetUrl)) {
    header('HTTP/1.1 400 Bad Request');
    echo json_encode(['error' => 'URL parameter is required']);
    exit();
}

// Periksa apakah ini adalah request handler .ashx
if (strpos($targetUrl, '.ashx') !== false) {
    // Pastikan URL menggunakan format yang benar untuk handler .ashx di IIS
    if (strpos($targetUrl, '/api/') === false) {
        $targetUrl = preg_replace('/\.ashx/', '', $targetUrl);
        $targetUrl = rtrim($targetUrl, '/') . '/api/';
        $targetUrl = preg_replace('/\/api\/api\//', '/api/', $targetUrl) . '.ashx';
    }
}

// Whitelist URL yang diizinkan
$allowedDomains = [
    'http://localhost:58971',
    'http://127.0.0.1:58971',
    'http://penantian-001-site1.qtempurl.com'
];

$isAllowed = false;
foreach ($allowedDomains as $domain) {
    if (strpos($targetUrl, $domain) === 0) {
        $isAllowed = true;
        break;
    }
}

if (!$isAllowed) {
    header('HTTP/1.1 403 Forbidden');
    echo json_encode(['error' => 'URL tidak diizinkan']);
    exit();
}

// Tangani metode HTTP yang berbeda
$method = $_SERVER['REQUEST_METHOD'];
$requestBody = file_get_contents('php://input');
$headers = getallheaders();
$requestHeaders = [];

// Salin header yang relevan
foreach ($headers as $key => $value) {
    if (strtolower($key) !== 'host' && strtolower($key) !== 'connection') {
        $requestHeaders[] = "$key: $value";
    }
}

// Tambahkan header Content-Type jika tidak ada
if (!isset($headers['Content-Type'])) {
    $requestHeaders[] = "Content-Type: application/json";
}

// Debugging jika diperlukan
$debug = isset($_GET['debug']) && $_GET['debug'] == 1;
if ($debug) {
    error_log("Proxy request: $method $targetUrl");
    error_log("Headers: " . json_encode($requestHeaders));
    error_log("Body: $requestBody");
}

// Inisialisasi cURL
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $targetUrl);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, $requestHeaders);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); // Dinonaktifkan untuk pengembangan
curl_setopt($ch, CURLOPT_TIMEOUT, 30); // Timeout setelah 30 detik

// Tambahkan body jika ada
if ($method === 'POST' || $method === 'PUT') {
    curl_setopt($ch, CURLOPT_POSTFIELDS, $requestBody);
}

// Eksekusi request
$response = curl_exec($ch);
$error = curl_error($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$contentType = curl_getinfo($ch, CURLINFO_CONTENT_TYPE);
curl_close($ch);

// Tangani error
if ($error) {
    header('HTTP/1.1 500 Internal Server Error');
    echo json_encode(['error' => "cURL error: $error"]);
    if ($debug) {
        error_log("cURL error: $error");
    }
    exit();
}

// Kirim response ke client
http_response_code($httpCode);
if ($contentType) {
    header("Content-Type: $contentType");
}
echo $response;
?>