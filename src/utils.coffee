utils = { }

utils.parseDate = (str) ->
  return false unless str
  currentDate = new Date

  # Dates with the format (D)D/(M)M/(YY)YY or (D)D.(M)M.(YY)YY
  generalRE = RegExp "^(\\d{1,2})([/\\.](\\d{1,2}))?([/\\.](\\d{2,4}))?$", "g"
  match = generalRE.exec str
  if match
    [__, day, __, month, __, year] = match
    if year and year.length == 2 then year = "20#{year}" 
    date = new Date(
      year or currentDate.getUTCFullYear()
      if month then month-1 else currentDate.getUTCMonth()
      day or currentDate.getDate()
    )
    return date

  # Today
  return new Date if /^\s*t$/g.test str

  # Yesterday
  match = str.match /y/g
  return new Date Date.now() - match.length*24*36e5 if match

  # Weekdays
  weekday = currentDate.getDay() # the current weekday
  if /mon/gi.test str
    diff = if weekday == 1 then 0 else weekday - 1
  else if /tue/gi.test str
    diff = if weekday == 2 then 0 else (if weekday > 2 then weekday-2 else weekday+5)
  else if /wed/gi.test str
    diff = if weekday == 3 then 0 else (if weekday > 3 then weekday-3 else weekday+4)
  else if /thu/gi.test str
    diff = if weekday == 4 then 0 else (if weekday > 4 then weekday-4 else weekday+3)
  else if /fri/gi.test str
    diff = if weekday == 5 then 0 else (if weekday > 5 then weekday-5 else weekday+2)
  else if /sat/gi.test str
    diff = if weekday == 6 then 0 else (if weekday > 6 then weekday-6 else weekday+1)
  else if /sun/gi.test str
    diff = if weekday == 7 then 0 else weekday
  else return undefined
  return new Date new Date().getTime()-(diff*24*36e5)

currencySymbols =
  'EUR': '€'
  'USD': '$'
  'GPB': '£'

utils.formatPrice = (price, n) ->
  unless price.amount? then return undefined
  amount = (price.amount*(n or 1)).toFixed 2
  currency = price.currency
  currencySymbol = currencySymbols[currency] or currency
  return amount+(currencySymbol or '')

utils.formatDate = (date, str) ->
  return '' unless date? and date instanceof Date
  # Needs to be expanded
  "#{date.getDate()}/#{date.getMonth()+1}/#{date.getFullYear()}"

utils.weekdays = ['Sunday','Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
utils.shortWeekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

module.exports = utils
