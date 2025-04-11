<?php
header('Content-Type: text/event-stream');
header('Cache-Control: no-cache');
header('Connection: keep-alive');

function getCpuUsage() {
	$load = sys_getloadavg();
	error_log("CPU Load: " . implode(', ', $load));
	return round($load[0] * 100 / max(1, shell_exec('nproc'))) . '%';
}

while (true) {
    $cpuUsage = getCpuUsage();
    echo "data: " . json_encode([
            'cpu' => $cpuUsage,
            'time' => date('H:i:s')
    ]) . "\n\n";

    ob_flush();
    flush();

    if (connection_aborted()) break;
    sleep(1);
}
