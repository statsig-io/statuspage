const maxDays = 30;

async function genReportLog(container, key, url) {
  const response = await fetch('/' + key + '_report.log');
  const statusLines = await response.text();
  
  const normalized = normalizeData(statusLines);
  const statusStream = constructStatusStream(key, url, normalized);
  container.appendChild(statusStream);
}

function constructStatusStream(key, url, uptimeData) {
  let streamContainer = templatize('statusStreamContainerTemplate');
  for (var ii = maxDays - 1; ii >= 0; ii--) {
    let line = constructStatusLine(key, ii, uptimeData[ii]);
    streamContainer.appendChild(line);
  }

  const lastSet = uptimeData[0];
  const lastQuartile = lastSet.q4 ?? (lastSet.q3 ?? (lastSet.q2 ?? lastSet.q1));
  const color = getColor(lastQuartile);
  
  const container = templatize('statusContainerTemplate', { 
    title: key, 
    url: url, 
    color: color, 
    status: getStatusText(color),
  });
  
  container.appendChild(streamContainer);
  container.appendChild(templatize('uptimeTemplate', { upTime: uptimeData.upTime }));
  return container;
}

function constructStatusLine(key, relDay, quartiles) {
  let line = templatize('statusLineTemplate')
  let date = new Date();
  date.setDate(date.getDate() - relDay);

  if (quartiles) {
    for (const [quartile, val] of Object.entries(quartiles)) {
      if (quartile === 'date') { continue; }
      line.insertBefore(constructStatusSquare(key, date, quartile, val), line.firstChild);
    }
  } else {
    for (const quartile of ['q1', 'q2', 'q3', 'q4']) {
      line.appendChild(constructStatusSquare(key, date, quartile, null));
    }
  }

  return line;
}

function getColor(uptimeVal) {
  return uptimeVal == null ? 'nodata' : 
    uptimeVal == 1 ? 'success' :
    uptimeVal < 0.3 ? 'failure' : 'partial';
}

function constructStatusSquare(key, date, quartile, uptimeVal) {
  const color = getColor(uptimeVal);
  let square = templatize('statusSquareTemplate', {
    color: color,
    tooltip: getTooltip(key, date, quartile, color),
  });

  const show = () => {
    showTooltip(square, key, date, quartile, color);
  };
  square.addEventListener('mouseover', show);
  square.addEventListener('mousedown', show);
  square.addEventListener('mouseout', hideTooltip);
  return square;      
}

let cloneId = 0;
function templatize(templateId, parameters) {
  let clone = document.getElementById(templateId).cloneNode(true);
  clone.id = 'template_clone_' + cloneId++;
  if (!parameters) {
    return clone;
  }

  applyTemplateSubstitutions(clone, parameters);      
  return clone;
}

function applyTemplateSubstitutions(node, parameters) {
  const attributes = node.getAttributeNames();
  for (var ii = 0; ii < attributes.length; ii++) {
    const attr = attributes[ii];
    const attrVal = node.getAttribute(attr);
    node.setAttribute(attr, templatizeString(attrVal, parameters))
  }

  if (node.childElementCount == 0) {
    node.innerText = templatizeString(node.innerText, parameters);
  } else {
    const children = Array.from(node.children);
    children.forEach((n) => {
      applyTemplateSubstitutions(n, parameters);
    })
  }
}

function templatizeString(text, parameters) {
  if (parameters) {
    for (const [key, val] of Object.entries(parameters)) {
      text = text.replaceAll('$' + key, val);
    }
  }
  return text;
}

function getStatusText(color) {
  return color == 'nodata' ? 'No Data Available' :
    color == 'success' ? 'All operational' :
    color == 'failure' ? 'Issues Detected' :
    color == 'partial' ? 'Partial Outage' : 'Unknown';
}

function getStatusDescriptiveText(color) {
  return color == 'nodata' ? 'No Data Available: Health check was not performed.' :
    color == 'success' ? 'All systems 100% operational.' :
    color == 'failure' ? 'The system was down as seen from health-checker during this period.' :
    color == 'partial' ? 'There were some periods of instability in the service.' : 'Unknown';
}

function getTooltip(key, date, quartile, color) {
  let statusText = getStatusText(color);      
  return `${key} | ${date.toDateString()} : ${quartile} : ${statusText}`;
}

function create(tag, className) {
  let element = document.createElement(tag);
  element.className = className;
  return element;
}

function normalizeData(statusLines) {
  const rows = statusLines.split('\n');
  const dateNormalized = splitRowsByDate(rows);
  
  let relativeDateMap = {};
  const now = Date.now();
  for (const [key, val] of Object.entries(dateNormalized)) {
    if (key == 'upTime') {
      continue;
    }

    const relDays = getRelativeDays(now, new Date(key).getTime());
    const avgQuartiles = getAverageQuartiles(val);
    
    relativeDateMap[relDays] = avgQuartiles;
  }

  relativeDateMap.upTime = dateNormalized.upTime;
  return relativeDateMap;
}

function getAverageQuartiles(quartiles) {
  let avgMap = {};
  for (const [key, val] of Object.entries(quartiles)) {
    if (!val || val.length == 0) {
      avgMap[key] = null;
    } else {
      avgMap[key] = val.reduce((a, v) => a + v) / val.length;
    }
  }

  return avgMap;
}

function getAverageValue(arr) {
  return arr.reduce((a, v) => a + v) / arr.length;
}

function getRelativeDays(date1, date2) { 
  return Math.floor(Math.abs((date1 - date2) / (24 * 3600 * 1000)));
}

function splitRowsByDate(rows) {
  let dateValues = {};
  let sum = 0, count = 0;
  for (var ii = 0; ii < rows.length; ii++) {
    const row = rows[ii];
    if (!row) {
      continue;
    }

    const [dateTimeStr, resultStr] = row.split(',', 2);
    const dateTime = new Date(dateTimeStr.replace(/-/g, '/'));
    const dateStr = dateTime.toDateString();

    let resultArray = dateValues[dateStr];
    if (!resultArray) {
      resultArray = { q1: [], q2: [], q3: [], q4: [] };
      dateValues[dateStr] = resultArray;
    }

    let result = 0;
    if (resultStr.trim() == 'success') {
      result = 1;
    }
    sum += result;
    count++;

    const qk = getQuarterKey(dateTime);
    resultArray[qk].push(result);
  }

  const upTime = (sum / count * 100).toFixed(2) + "%";
  dateValues.upTime = upTime;
  return dateValues;
}

function getQuarterKey(dateTime) {
  const hr = dateTime.getHours();
  return (
    hr < 6 ? 'q1' : hr < 12 ? 'q2' : hr < 18 ? 'q3' : 'q4'
  );
}

function getQuartileText(quartile) {
  switch (quartile) {
    case 'q1':
      return '00:00-06:00hrs';
    case 'q2':
      return '06:00-12:00hrs';
    case 'q3':
      return '12:00-18:00hrs';
    case 'q4':
      return '18:00-24:00hrs';
    default:
      return 'wut?'
  }
}

let tooltipTimeout = null;
function showTooltip(element, key, date, quartile, color) {
  clearTimeout(tooltipTimeout);
  const toolTipDiv = document.getElementById('tooltip');
  document.getElementById('tooltipDateTime').innerText = date.toDateString();
  document.getElementById('tooltipKey').innerText = key;
  document.getElementById('tooltipQuartile').innerText = getQuartileText(quartile);
  document.getElementById('tooltipStatus').innerText = getStatusDescriptiveText(color);
  toolTipDiv.style.top = element.offsetTop + element.offsetHeight + 4;
  toolTipDiv.style.left = element.offsetLeft + element.offsetWidth / 2 - toolTipDiv.offsetWidth / 2;
  toolTipDiv.style.opacity = "1";
}

function hideTooltip() {
  tooltipTimeout = setTimeout(() => 
  {
    const toolTipDiv = document.getElementById('tooltip');
    toolTipDiv.style.opacity = "0";
  }, 1000);  
}

async function genAllReports() {
  const response = await fetch('/urls-config.txt');
  const configText = await response.text();
  const configLines = configText.split('\n');
  for (let ii = 0; ii < configLines.length; ii++) {
    const configLine = configLines[ii];
    const [key, url] = configLine.split('=');
    if (!key || !url) {
      continue;
    }

    await genReportLog(document.getElementById('reports'), key, url);
  }
}