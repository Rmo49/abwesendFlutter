function callPhpLocal() {
    //alert("callPhp()");
     console.log("callPhpLocal()");
    var http = new XMLHttpRequest();
    var url = 'http://192.168.0.59:8081/db/testConnect.php';
    var params = '';
    http.open('POST', url, true);

    //Send the proper header information along with the request
    http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

    http.onreadystatechange = function() {//Call a function when the state changes.
        if(http.readyState == 4 && http.status == 200) {
            alert(http.responseText);
        }
    }
    http.send(params);
}

function callPhpNomadus1() {
    //alert("callPhp()");
    console.log("callPhpNomadus1()");
    var http = new XMLHttpRequest();
    var url = 'https://nomadus.ch/tca/db/testConnect.php';
    var params = '';
    http.open('POST', url, true);

    //Send the proper header information along with the request
    http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

    http.onreadystatechange = function() {//Call a function when the state changes.
        if(http.readyState == 4 && http.status == 200) {
            alert(http.responseText);
        }
    }
    http.send(params);
}

function callPhpNomadus2() {
    var xhr = new XMLHttpRequest();
    var url = 'https://nomadus.ch/tca/db/testConnect.php';

    xhr.open('POST', url, true);
 //   xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    xhr.onload = function () {
        // do something to response
        alert(this.responseText);
    };
//    xhr.send('user=person&pwd=password&organization=place&requiredkey=key');
    xhr.send();
}
