String to12hr(String s) {
  var time = s.split(":");
  var hr = time[0];
  var mn = time[1];
  var meridian = "AM";
  if (int.parse(hr) >= 12) {
    meridian = "PM";
    hr = (int.parse(hr) - 12).toString();
  }
  if (hr == "0") {
    hr = "12";
  }
  return hr + ":" + mn + " " + meridian;
}
