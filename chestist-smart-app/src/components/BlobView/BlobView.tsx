import React, { FC, useState, useEffect } from 'react';
import { InteractiveBrowserCredential } from '@azure/identity';
import { BlobServiceClient, BlobItem } from '@azure/storage-blob';


const BlobView: FC<{}> = () => {
    const [blobList, setBlobList] = useState<Array<BlobItem>>([]);

    useEffect(() => {
        const signInOptions = {
            clientId: "8a097d51-6cb3-49b7-8e2a-d9d3ad192584",
            tenantId: "c2c1d092-cf24-4636-a284-203c93601579"
        }

        const blobStorageClient = new BlobServiceClient(
            "https://chestistdemo.blob.core.windows.net/",
            new InteractiveBrowserCredential(signInOptions)
        )

        const fetchData = async () => {
            var containerClient = blobStorageClient.getContainerClient("images");
            var localBlobList = [];
            let iterator = await containerClient.listBlobsFlat().byPage({maxPageSize: 5});
            let response = (await iterator.next()).value;

            for (const blob of response.segment.blobItems) {
                localBlobList.push(blob);
            }
            setBlobList(localBlobList);
        }

        fetchData();
    }, []);

    return (
        <div>
            <div className="health-record__header">
                <div className="header-title">Images from Storage</div>
                <div className="header-divider"></div>
            </div>
            <table className="table table-sm table-hover">
                <thead>
                    <tr>
                        <th>Image Name</th>
                        <th>Size</th>
                        <th>Thumbnail</th>
                    </tr>
                </thead>
                <tbody>{
                    blobList.map((x, i) => {
                        return <tr key={i}>
                            <td>{x.name}</td>
                            <td>{x.properties.contentLength}</td>
                            <td>
                                <img height="200" width="200" src={'https://images-func-zeckcg7jlal6q.azurewebsites.net/api/image/' + x.name} />
                            </td>
                        </tr>
                    })
                }
                </tbody>
            </table>
        </div>
    )
}

export default BlobView;