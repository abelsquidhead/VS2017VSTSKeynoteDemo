using OpenQA.Selenium;

namespace AutomatedUITests.Page
{
    public class AboutPage
    {
        protected IWebDriver _driver;

        public AboutPage(IWebDriver driver)
        {
            _driver = driver;
        }
    }
}