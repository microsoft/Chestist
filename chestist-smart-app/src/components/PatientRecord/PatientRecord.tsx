import React, { FC } from 'react';
import { usePatient } from '../PatientProvider';

import {
  MediaVisualizer,
  PatientVisualizer
} from 'fhir-visualizers';

import BlobView from '../BlobView';

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
      <BlobView />
      <MediaVisualizer rows={getResourceByType(resources, 'Media')} />
    </div>
  );
};

export default PatientRecord;
