Bahmni.Registration.AttributesConditions.rules = {
    'age': function (a) {
        var returnValues = {
            show:[],
            hide:[]
        };
        if (a["age"].years < 10) {
            returnValues.hide.push("extraAddressInfo") //just testing
        } else {
            returnValues.show.push("extraAddressInfo")
        }
    }
};