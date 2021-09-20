import React, { FC } from 'react';
import { usePatient } from '../PatientProvider';

import {
  EncountersVisualizer,
  ObservationsVisualizer,
  PatientVisualizer
} from 'fhir-visualizers';

type PatientRecordProps = {
  resources: ReadonlyArray<Record<string, any>>;
};

const getResourceByType = (patientRecord: ReadonlyArray<any>, resourceType: string) => {
  return patientRecord.filter((resource) => resource.resourceType === resourceType);
};

const PatientRecord: FC<PatientRecordProps> = ({ resources }) => {
  const patient = usePatient();

  return (
    <div>
      <PatientVisualizer patient={patient} />
      <ObservationsVisualizer rows={getResourceByType(resources, 'Observation')} />
      <EncountersVisualizer rows={getResourceByType(resources, 'Encounter')} />
    </div>
  );
};

export default PatientRecord;
