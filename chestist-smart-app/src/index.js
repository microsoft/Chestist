import React from 'react';
import ReactDOM from 'react-dom';
import FHIR from 'fhirclient';

import App from './components/App.tsx';
import './styles/index.scss';
import './utils/fontawesomeLibrary';

const rootElement = document.getElementById('root');

const smartLaunch = () => {
  // Authorize application
  FHIR.oauth2
    .init({
      clientId: '20560ea5-f224-4658-b667-4e6bab935c85',
      scope: 'launch/patient openid profile'
    })
    .then(client => {
      ReactDOM.render(<App client={client} />, rootElement);
    });
};

smartLaunch();
