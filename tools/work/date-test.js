var d,
	console = { log:print };

 console.log( (d = new Date("1974-07-14 01:15")).toString() + " = " + d.valueOf() + " === " + d.toISOString());
 console.log( (d = new Date("1974")).toString() + " = " + d.valueOf() + " === exception");
 console.log( (d = new Date("+1974-07-14 01:15")).toString() + " = " + d.valueOf() + " === exception");
 console.log( (d = new Date("0074-07-14 01:15")).toString() + " = " + d.valueOf() + " === " + d.toISOString());
 console.log( (d = new Date("74-07-14 01:15")).toString() + " = " + d.valueOf() + " === exception");
 console.log( (d = new Date("-000074-07-14 01:15")).toString() + " = " + d.valueOf() + " === " + d.toISOString());
 console.log( (d = new Date("+001974-07-14 01:15")).toString() + " = " + d.valueOf() + " === " + d.toISOString());
 console.log( (d = new Date("1974-07-14T01:15:16.017Z")).toString() + " = " + d.valueOf() + " === " + d.toISOString());
 console.log( (d = new Date("1974-07-14T01:15:16.017+01:00")).toString() + " = " + d.valueOf() + " === " + d.toISOString());
 console.log( (d = new Date("1974-07-14T01:15:16.017+02")).toString() + " = " + d.valueOf() + " === " + d.toISOString());
 console.log( (d = new Date("1974-07-14T01:15:16+03")).toString() + " = " + d.valueOf() + " === " + d.toISOString());
 console.log( (d = new Date("1974-07-14T01:15:16+04")).toString() + " = " + d.valueOf() + " === " + d.toISOString());
 console.log( (d = new Date("1974-07-14T01:15+05:")).toString() + " = " + d.valueOf() + " === " + d.toISOString());
 console.log( (d = new Date("1974-07-14 01:15:16 +0200")).toString() + " = " + d.valueOf() + " === " + d.toISOString());
 console.log( (d = new Date("1974-07-14 01:15:16 GMT-01:30")).toString() + " = " + d.valueOf() + " === " + d.toISOString());

// console.log( (d = new Date(1603585029123 + -3*60*60*1000)).valueOf() + " = " + String( d ) + " / " + d.toUTCString() + " / " + d.toISOString() + " ("+d.getTimezoneOffset()+")" )
// console.log( (d = new Date(1603585029123 + -2*60*60*1000)).valueOf() + " = " + String( d ) + " / " + d.toUTCString() + " / " + d.toISOString() + " ("+d.getTimezoneOffset()+")" )
// console.log( (d = new Date(1603585029123 + -1*60*60*1000)).valueOf() + " = " + String( d ) + " / " + d.toUTCString() + " / " + d.toISOString() + " ("+d.getTimezoneOffset()+")" )
// console.log( (d = new Date(1603585029123 + 0*60*60*1000)).valueOf() + " = " + String( d ) + " / " + d.toUTCString() + " / " + d.toISOString() + " ("+d.getTimezoneOffset()+")" )
// console.log( (d = new Date(1603585029123 + 1*60*60*1000)).valueOf() + " = " + String( d ) + " / " + d.toUTCString() + " / " + d.toISOString() + " ("+d.getTimezoneOffset()+")" )
// console.log( (d = new Date(1603585029123 + 2*60*60*1000)).valueOf() + " = " + String( d ) + " / " + d.toUTCString() + " / " + d.toISOString() + " ("+d.getTimezoneOffset()+")" )
// console.log( (d = new Date(1603585029123 + 3*60*60*1000)).valueOf() + " = " + String( d ) + " / " + d.toUTCString() + " / " + d.toISOString() + " ("+d.getTimezoneOffset()+")" )

// console.log( d.toDateString() );
// console.log( d.toTimeString() );
// console.log( d.toString() );
// console.log( d.toUTCString() );
// console.log( d.valueOf() );
// console.log( d.getTime() );
// console.log( d.getFullYear() );
// console.log( d.getUTCFullYear() );
// console.log( d.getMonth() );
// console.log( d.getUTCMonth() );
// console.log( d.getDate() );
// console.log( d.getUTCDate() );
// console.log( d.getDay() );
// console.log( d.getUTCDay() );
// console.log( d.getHours() );
// console.log( d.getUTCHours() );
// console.log( d.getMinutes() );
// console.log( d.getUTCMinutes() );
// console.log( d.getSeconds() );
// console.log( d.getUTCSeconds() );
// console.log( d.getMilliseconds() );
// console.log( d.getUTCMilliseconds() );
// console.log( d.getTimezoneOffset() );

// console.log( d.setTime(123) );
// console.log( d.setMilliseconds(123) );
// console.log( d.setUTCMilliseconds(123) );
// console.log( d.setSeconds(123) );
// console.log( d.setUTCSeconds(123) );
// console.log( d.setMinutes(123) );
// console.log( d.setUTCMinutes(123) );
// console.log( d.setHours(123) );
// console.log( d.setUTCHours(123) );
// console.log( d.setDate(123) );
// console.log( d.setUTCDate(123) );
// console.log( d.setMonth(123) );
// console.log( d.setUTCMonth(123) );
// console.log( d.setFullYear(123) );
// console.log( d.setUTCFullYear(123) );

// console.log("2020-10-25 00:17:09.123 = " + (new Date(2020,9,25,0,17,9,123)).valueOf() + " == 1603577829123 / " + (new Date(2020,9,25,0,17,9,123)).toString());
// console.log("2020-10-25 01:17:09.123 = " + (new Date(2020,9,25,1,17,9,123)).valueOf() + " == 1603581429123 / " + (new Date(2020,9,25,1,17,9,123)).toString());
// console.log("2020-10-25 02:17:09.123 = " + (new Date(2020,9,25,2,17,9,123)).valueOf() + " == 1603585029123 / " + (new Date(2020,9,25,2,17,9,123)).toString());
// console.log("2020-10-25 03:17:09.123 = " + (new Date(2020,9,25,3,17,9,123)).valueOf() + " == 1603592229123 / " + (new Date(2020,9,25,3,17,9,123)).toString());

// console.log("2020-03-29 00:17:09.123 = " + (new Date(2020,2,29,0,17,9,123)).valueOf() + " == 1585437429123 / " + (new Date(2020,2,29,0,17,9,123)).toString());
// console.log("2020-03-29 01:17:09.123 = " + (new Date(2020,2,29,1,17,9,123)).valueOf() + " == 1585441029123 / " + (new Date(2020,2,29,1,17,9,123)).toString());
// console.log("2020-03-29 02:17:09.123 = " + (new Date(2020,2,29,2,17,9,123)).valueOf() + " == 1585444629123 / " + (new Date(2020,2,29,2,17,9,123)).toString());
// console.log("2020-03-29 03:17:09.123 = " + (new Date(2020,2,29,3,17,9,123)).valueOf() + " == 1585444629123 / " + (new Date(2020,2,29,3,17,9,123)).toString());

// console.log( (new Date(2020,9,25,1,17,9,123)).toString() + " = " + (new Date(2020,9,25,1,17,9,123)).valueOf() );
// console.log( (new Date(2020,9,25,2,17,9,123)).toString() + " = " + (new Date(2020,9,25,2,17,9,123)).valueOf() );
// console.log( (new Date(2020,9,25,3,17,9,123)).toString() + " = " + (new Date(2020,9,25,3,17,9,123)).valueOf() );
// console.log("");

// console.log( (new Date()).toString() );

// console.log( (new Date(-51506840571000)).toISOString() ); 
// console.log( (new Date(-51506840571000)).toString() ); 

// console.log((new Date(377,2,27,1,44,18)).valueOf());
// console.log((new Date(377,2,27,1,44,18)).toISOString());
// console.log((new Date(-50262851742000 + 60*60*1000)).toISOString());

// console.log(new Date(1999,9,31,2,13,41).valueOf());

// console.log(new Date(-1999,9,20,2,13,41).toISOString());

// console.log(new Date(1974,6,14,1,15,16,17).toString());
// console.log(new Date(1974,6,14,1,15,16,17).toUTCString());
// console.log(new Date(1974,6,14,1,15,16,17).toISOString());
// console.log(new Date(12345,6,14,1,15,16,17).toString());
// console.log(new Date(123456,6,14,1,15,16,17).toUTCString());
