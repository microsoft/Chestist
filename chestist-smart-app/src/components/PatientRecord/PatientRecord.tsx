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
      <BlobView 
        clientId="8a097d51-6cb3-49b7-8e2a-d9d3ad192584" 
        tenantId="c2c1d092-cf24-4636-a284-203c93601579" 
        storageAccount="chestistdemo" 
        imageFuncUrl="https://images-func-zeckcg7jlal6q.azurewebsites.net/api/image/" />
      <MediaVisualizer rows={getResourceByType(resources, 'Media')} />
    </div>
  );
};

export default PatientRecord;
