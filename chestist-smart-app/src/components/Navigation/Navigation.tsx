import React, { FC } from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import PatientSnapshot from 'components/PatientSnapshot';

import classes from './Navigation.module.scss';

type Option = {
  label: string;
  value: string;
};

const Navigation: FC<{}> = () => {
  return (
    <nav className={classes.navigation}>
      <div className={classes['navigation__left-panel']}>
        <FontAwesomeIcon icon="chevron-left" className={classes.navigation__back} />

        <PatientSnapshot />
      </div>

      <div className={classes['navigation__right-panel']}>
        
      </div>
    </nav>
  );
};

export default Navigation;
