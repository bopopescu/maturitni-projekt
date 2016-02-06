/* function loaded on page load */
function homePageOnLoad()
{
    var signup_form = document.getElementById("signup-form");
    signup_form.addEventListener("submit", register);
}



window.onhashchange = function()
{
  switch(location.hash) {
    case '#about':
        $("#navbar-home-button").removeClass("active");
        $("#navbar-about-button").addClass("active");
    break;
    case '#top':
        $("#navbar-home-button").addClass("active");
        $("#navbar-about-button").removeClass("active");
        $('html,body').scrollTop(0);
    break
  }
}

/*
 *  register(event): function called upon submitting the registration form;
 *  makes an api call to register an account
 */
function register(event)
{
    var posting = $.post("http://localhost:5000/register",
    {
        email: $("#signup-form input[id=email]").val(),
        password: $("#signup-form input[id=pwd]").val()
    }, dataType='json'
    );

    posting.done(function(data)
    {
        console.log(data);
        json_parsed = data;
        if(json_parsed["status"] == "ok" && json_parsed["reason"] == "reg_success")
        {
            window.location = "login.html#regsuccess";
        }
        else if(json_parsed["status"] == "error")
        {
            console.log(json_parsed["message"]);
            general_dialog("Registration failed", json_parsed["message"], "error", 2);
        }
    });

    posting.fail(function()
    {
         general_dialog("Registration failed", "An error occurred while trying to contact the API server.", "error", 2);
    });

    event.preventDefault();
    return false;
}



