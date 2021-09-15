import React from 'react';
import ReactDOM from 'react-dom';
import FHIR from 'fhirclient';

import App from './components/App.tsx';
import './styles/index.scss';
import './utils/fontawesomeLibrary';
import { env } from 'process';

const rootElement = document.getElementById('root');

const smartLaunch = () => {
  // Authorize application
  FHIR.oauth2
    .init({
      clientId: env.CLIENT_ID,
      scope: 'launch/patient openid profile'
    })
    .then(client => {
      ReactDOM.render(<App client={client} />, rootElement);
    });
};

smartLaunch();
